# ADR-005: Central KI Management

**Date**: 2026-03-03  
**Type**: Enabling  
**Status**: DRAFT  
**Author**: Legacy Analysis (/legacy)

---

## Context

The Simbox system uses multi-SIM adapters that require:
- KI (cryptographic key) programming
- IMSI/ICCID credential management
- Secure storage of authentication data
- Synchronization across multiple simbox instances

Multi-SIM adapters need periodic KI rotation to:
- Evade carrier fraud detection
- Replace blocked SIM profiles
- Maintain service continuity

## Problem

How to manage KI credentials for multiple simbox instances:
- Centralized KI generation and distribution
- Secure storage of KI database
- Synchronization of KI state
- Upload of balance/stats from simbox to central

## Decision

**Implement central KI server** (`simserver:8122`) for centralized credential management.

### Architecture

```
                    ┌─────────────────┐
                    │   simserver:8122 │
                    │  (central mgmt) │
                    │                 │
                    │  - KI database  │
                    │  - Balance DB   │
                    │  - Stats DB     │
                    └────────┬────────┘
                             │ HTTP API
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
  ┌─────▼─────┐      ┌──────▼──────┐      ┌──────▼──────┐
  │ Simbox #1 │      │  Simbox #2  │      │  Simbox #N  │
  │           │      │             │      │             │
  │ KI client │      │  KI client  │      │  KI client  │
  └───────────┘      └─────────────┘      └─────────────┘
```

### API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/new_ki.php` | GET | Fetch new KI credentials |
| `/balance.php` | GET | Upload SIM balance |
| `/tarif.php` | GET | Upload tariff info |
| `/number.php` | GET | Upload phone number |
| `/op.php` | GET | Upload operator info |
| `/in.php` | GET | Notify incoming call |
| `/upload_ki.php` | GET | Confirm KI programming |

### KI Fetch Flow

```php
// system/new_ki.php
$ki_data = file_get_contents("http://simserver:8122/new_ki.php");
// Response format:
// KI:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// IMSI:250201234567890
// ICCID:89701234567890123456
// SMSC:+79991234567

// Parse response
preg_match('/KI:([A-F0-9]{32})/', $ki_data, $ki_match);
preg_match('/IMSI:(\d{15,18})/', $ki_data, $imsi_match);
preg_match('/ICCID:(\d{19,20})/', $ki_data, $iccid_match);

// Program the adapter
program_ki($dongle, $ki, $imsi, $iccid);

// Confirm to server
file_get_contents("http://simserver:8122/upload_ki.php?imsi=$imsi&status=ok");
```

### Balance Upload Flow

```php
// modules/sim.php
function upload_balance($imsi, $balance) {
    $url = "http://simserver:8122/balance.php";
    $params = http_build_query([
        'imsi' => $imsi,
        'balance' => $balance,
        'timestamp' => time()
    ]);
    file_get_contents("{$url}?{$params}");
}

function upload_tarif($imsi, $tarif) {
    $url = "http://simserver:8122/tarif.php";
    $params = http_build_query([
        'imsi' => $imsi,
        'tarif' => $tarif
    ]);
    file_get_contents("{$url}?{$params}");
}
```

### Incoming Call Notification

```php
// Asterisk dialplan -> in.php
// Called from extensions_incoming.conf
System(
    curl -s "http://simserver:8122/in.php?
    numberb=${NUMBERB}&
    numbermy=${NUMBERMY}&
    imei=${IMEI}&
    imsi=${IMSI}&
    dongle=${DONGLE}&
    uid=${UNIQUEID}"
);
```

### Security Characteristics

| Aspect | Current State |
|--------|---------------|
| Transport | HTTP (unencrypted) |
| Authentication | None (IP-based trust) |
| KI Storage | Server-side database |
| Client Auth | None |
| Data Integrity | No signatures |

## Consequences

### Positive

- **Centralization**: Single source of truth for KI credentials
- **Scalability**: Multiple simbox instances share KI pool
- **Monitoring**: Central stats collection
- **Automation**: KI rotation can be automated server-side
- **Audit Trail**: Central logging of all operations

### Negative

- **Single Point of Failure**: simserver down = no new KI
- **Security**: HTTP transmission of sensitive KI
- **No Authentication**: Any client can upload data
- **Network Dependency**: Requires network connectivity
- **Privacy**: All simbox activity visible to central server

### Operational Concerns

- simserver availability critical
- Network latency affects KI programming time
- No offline KI provisioning
- Balance sync depends on connectivity

## Implementation Notes

- Server runs on port 8122 (non-standard)
- All endpoints use GET (not POST)
- No request/response validation
- PHP `file_get_contents()` for HTTP calls
- Timeout not configured (can hang)

## Related Decisions

- [ADR-001](../adr-001-file-based-state/): File-based state storage
- [ADR-002](../adr-002-imsi-centric-model/): IMSI-centric data model
- [ADR-003](../adr-003-multi-sim-adapter/): Multi-SIM adapter support

---

*Generated by /legacy analysis - 2026-03-03*
