# SDD: SIM Management

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Spec-Driven Development  
**Module**: SIM Management

---

## 01. Requirements

### Overview

SIM Management handles the complete lifecycle of SIM cards including KI programming, balance tracking, statistics, and central server synchronization.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Program KI credentials for Type 9 adapters | HIGH |
| FR-02 | Program KI credentials for Type 16 adapters | HIGH |
| FR-03 | Fetch new KI from central server | HIGH |
| FR-04 | Upload balance to central server | HIGH |
| FR-05 | Upload tariff info to central server | HIGH |
| FR-06 | Upload phone number to central server | HIGH |
| FR-07 | Track SIM state (balance, limits, group) | HIGH |
| FR-08 | Support multi-SIM adapter profile switching | MEDIUM |
| FR-09 | Implement KI rotation for anti-detection | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | IMSI as primary identifier for all operations |
| NFR-02 | File-based state storage (no database) |
| NFR-03 | Central server sync on every balance change |
| NFR-04 | Support concurrent KI programming operations |
| NFR-05 | Russian language UI labels |

### Constraints

- Must work with existing multi-SIM adapter hardware
- Central server (simserver:8122) must be available
- HTTP protocol for server communication (no HTTPS)

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Central Server                        │
│                   simserver:8122                         │
│  ┌──────────────┬──────────────┬─────────────────────┐  │
│  │ KI Database  │ Balance DB   │ Statistics DB       │  │
│  └──────────────┴──────────────┴─────────────────────┘  │
└───────────────────────┬─────────────────────────────────┘
                        │ HTTP API
                        │
┌───────────────────────▼─────────────────────────────────┐
│                  SIM Management Module                   │
│  ┌──────────────────┬─────────────────────────────────┐ │
│  │ KI Programming   │ Balance/Stats Tracking          │ │
│  │ (modules/ki.php) │ (modules/sim.php)               │ │
│  ├──────────────────┼─────────────────────────────────┤ │
│  │ - program_ki_    │ - save_balance()                │ │
│  │   type9()        │ - upload_balance()              │ │
│  │ - program_ki_    │ - upload_tarif()                │ │
│  │   type16()       │ - upload_number()               │ │
│  │ - verify_ki()    │ - upload_op()                   │ │
│  └──────────────────┴─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### SIM Card Lifecycle

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  Fetch  │────►│ Program │────►│ Verify  │────►│  Upload │
│   KI    │     │  Adapter│     │Success  │     │  Stats  │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
     │                               │
     │                               ▼
     │                        ┌─────────────┐
     └────────────────────────│   Central   │
                              │   Server    │
                              └─────────────┘
```

### Adapter Types

| Type | Name | Interface | Commands |
|------|------|-----------|----------|
| Type 9 | STK Adapter | SIM Toolkit | AT+STGR, AT+STIN, AT+STSF |
| Type 16 | SuperSIM | CSIM APDU | AT+CSIM |

### State Files per SIM

All files keyed by IMSI:

```
/var/simbox/sim/statistics/$imsi.balance      # Current balance
/var/simbox/sim/statistics/$imsi.bal_last     # Last known balance
/var/simbox/sim/statistics/$imsi.bal_minus    # Total spent
/var/simbox/sim/statistics/$imsi.bal_plus     # Total added
/var/simbox/sim/statistics/$imsi.bal_yest     # Yesterday's balance
/var/simbox/sim/statistics/$imsi.op_t         # Operator type
/var/simbox/sim/statistics/$imsi.op_d         # Operator date
/var/simbox/sim/settings/$imsi.tarif          # Tariff name
/var/simbox/sim/settings/$imsi.number         # Phone number
/var/simbox/sim/settings/$imsi.owner          # SIM owner ID
/var/simbox/sim/settings/$imsi.group          # Routing group
/var/simbox/sim/settings/$imsi.ki             # KI (encrypted)
/var/simbox/sim/settings/$imsi.iccid          # ICCID
/var/simbox/sim/settings/$imsi.smsc           # SMSC number
```

### KI Programming Flow

```php
// system/new_ki.php

// 1. Fetch KI from central server
$ki_data = file_get_contents("http://simserver:8122/new_ki.php");
// Response:
// KI:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// IMSI:250201234567890
// ICCID:89701234567890123456
// SMSC:+79991234567

// 2. Parse credentials
preg_match('/KI:([A-F0-9]{32})/', $ki_data, $ki_match);
preg_match('/IMSI:(\d{15,18})/', $ki_data, $imsi_match);
preg_match('/ICCID:(\d{19,20})/', $ki_data, $iccid_match);

$ki = $ki_match[1];
$imsi = $imsi_match[1];
$iccid = $iccid_match[1];

// 3. Program adapter
require_once 'modules/ki.php';
$success = program_ki_type16($dongle, $ki, $imsi, $iccid);

// 4. Verify and upload
if ($success) {
    // Save local state
    file_put_contents("/var/simbox/sim/settings/{$imsi}.ki", $ki);
    file_put_contents("/var/simbox/sim/settings/{$imsi}.iccid", $iccid);
    
    // Confirm to server
    file_get_contents("http://simserver:8122/upload_ki.php?imsi=$imsi&status=ok");
}
```

### Balance Upload Flow

```php
// modules/sim.php

function save_balance($imsi, $balance) {
    $file = "/var/simbox/sim/statistics/{$imsi}.balance";
    file_put_contents($file, $balance);
}

function upload_balance($imsi, $balance) {
    // Save locally first
    save_balance($imsi, $balance);
    
    // Sync to central server
    $url = "http://simserver:8122/balance.php";
    $params = http_build_query([
        'imsi' => $imsi,
        'balance' => $balance,
        'timestamp' => time()
    ]);
    file_get_contents("{$url}?{$params}");
}

function upload_tarif($imsi, $tarif) {
    $file = "/var/simbox/sim/settings/{$imsi}.tarif";
    file_put_contents($file, $tarif);
    
    $url = "http://simserver:8122/tarif.php";
    $params = http_build_query(['imsi' => $imsi, 'tarif' => $tarif]);
    file_get_contents("{$url}?{$params}");
}

function upload_number($imsi, $number) {
    $file = "/var/simbox/sim/settings/{$imsi}.number";
    file_put_contents($file, $number);
    
    $url = "http://simserver:8122/number.php";
    $params = http_build_query(['imsi' => $imsi, 'number' => $number]);
    file_get_contents("{$url}?{$params}");
}
```

### Interface Definitions

#### KI Programming API

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `program_ki_type9` | `$dongle`, `$ki`, `$imsi`, `$iccid` | `bool` | Program Type 9 adapter |
| `program_ki_type16` | `$dongle`, `$ki`, `$imsi`, `$iccid` | `bool` | Program Type 16 adapter |
| `verify_ki` | `$dongle`, `$imsi` | `bool` | Verify KI programming |
| `fetch_new_ki` | void | `array` | Fetch from central server |

#### Balance/Stats API

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `save_balance` | `$imsi`, `$balance` | `void` | Save balance locally |
| `upload_balance` | `$imsi`, `$balance` | `void` | Sync to central |
| `upload_tarif` | `$imsi`, `$tarif` | `void` | Upload tariff |
| `upload_number` | `$imsi`, `$number` | `void` | Upload phone number |
| `upload_op` | `$imsi`, `$op_t`, `$op_d` | `void` | Upload operator info |

### Error Handling

```php
// KI programming errors
function program_ki_type16($dongle, $ki, $imsi, $iccid) {
    try {
        // Send APDU commands
        $result = send_apdu($dongle, $apdu);
        if (!$result) {
            error_log("KI programming failed for IMSI: $imsi");
            return false;
        }
        return true;
    } catch (Exception $e) {
        error_log("KI programming exception: " . $e->getMessage());
        return false;
    }
}

// Central server unavailable
function upload_balance($imsi, $balance) {
    save_balance($imsi, $balance);  // Always save locally
    
    $context = stream_context_create([
        'http' => ['timeout' => 5]  // 5 second timeout
    ]);
    
    $result = @file_get_contents($url, false, $context);
    if ($result === false) {
        error_log("Failed to upload balance for IMSI: $imsi");
        // Will retry on next operation
    }
}
```

### Security Considerations

- KI transmitted over HTTP (unencrypted)
- KI stored in plaintext file (should be encrypted)
- No authentication to central server
- File permissions critical (chmod 600 for KI files)

---

## 03. Implementation Plan

### Phase 1: KI Programming

- [ ] Review Type 9 adapter programming flow
- [ ] Review Type 16 adapter programming flow
- [ ] Add error handling for APDU failures
- [ ] Implement KI verification

### Phase 2: Balance Tracking

- [ ] Audit balance save/upload flow
- [ ] Add timeout for central server calls
- [ ] Implement retry logic for failed uploads

### Phase 3: Testing

- [ ] Test KI programming on both adapter types
- [ ] Test balance sync with central server
- [ ] Test error scenarios (server down, invalid KI)

---

## 04. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [ADR-002](../adr-002-imsi-centric-model/): IMSI-Centric Data Model
- [ADR-003](../adr-003-multi-sim-adapter/): Multi-SIM Adapter Support
- [ADR-005](../adr-005-central-ki/): Central KI Management
- [SDD: Dongle Control](../sdd-dongle-control/): USB modem management

---

*Generated by /legacy analysis - 2026-03-03*
