# SDD: Dongle Control

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Spec-Driven Development  
**Module**: Dongle Control

---

## 01. Requirements

### Overview

Dongle Control manages USB GSM modems including device initialization, AT command execution, power cycling, IMEI manipulation, and diagnostic mode operations.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Initialize USB modem via usb_modeswitch | HIGH |
| FR-02 | Execute AT commands via Asterisk chan_dongle | HIGH |
| FR-03 | Restart dongle via Asterisk CLI | HIGH |
| FR-04 | Change IMEI via Asterisk command | HIGH |
| FR-05 | Power cycle modem via USB hub control | MEDIUM |
| FR-06 | Toggle diagnostic mode | MEDIUM |
| FR-07 | Track dongle state (IMSI, ICCID, status) | HIGH |
| FR-08 | Support Huawei E1550, E173, E303/E353 | HIGH |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Integration with Asterisk chan_dongle module |
| NFR-02 | State persistence in /var/svistok/dongles/ |
| NFR-03 | Support for USB hub power control |
| NFR-04 | Russian language UI labels |

### Constraints

- Requires Asterisk with chan_dongle module
- USB hub must support power control (Terminus hubs)
- Huawei-specific AT commands

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Asterisk PBX                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │            chan_dongle Module (C)                  │ │
│  │  - GSM protocol stack                              │ │
│  │  - AT command interface                            │ │
│  │  - Call routing                                    │ │
│  └────────────────────────────────────────────────────┘ │
└───────────────────────┬─────────────────────────────────┘
                        │ CLI/AMI Interface
                        │
┌───────────────────────▼─────────────────────────────────┐
│                 Dongle Control Module                    │
│  ┌──────────────────┬─────────────────────────────────┐ │
│  │ AT Command       │ Power/Device Management         │ │
│  │ (modules/at.php) │ (actions/, programmator/)       │ │
│  ├──────────────────┼─────────────────────────────────┤ │
│  │ - send_at_cmd()  │ - restart_dongle()              │ │
│  │ - change_imei()  │ - power_cycle()                 │ │
│  │ - get_state()    │ - toggle_diag()                 │ │
│  └──────────────────┴─────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

### Supported Devices

| Device | Vendor ID | Product IDs |
|--------|-----------|-------------|
| Huawei E1550 | 0x12d1 | 0x14ac, 0x1446 |
| Huawei E173 | 0x12d1 | 0x1436, 0x1465 |
| Huawei E303 | 0x12d1 | 0x1465, 0x1506 |
| Huawei E353 | 0x12d1 | 0x1465, 0x1506 |

### USB Mode Switching

Huawei devices start in storage mode and need switching to modem mode:

```bash
# /etc/usb_modeswitch.d/12d1:14ac
# Huawei E1550
TargetVendor=0x12d1
TargetProduct=0x14ac
MessageContent="55534243123456780000000000000011062000000100000000000000000000"
```

### AT Command Interface

Commands executed via Asterisk CLI:

```bash
# Restart dongle
asterisk -rx "dongle restart now dongle01"

# Change IMEI
asterisk -rx "dongle changeimei dongle01 353456071234567"

# Send raw AT command
asterisk -rx "dongle cmd dongle01 AT+CFUN=1,1"

# Get dongle state
asterisk -rx "dongle show stats"
```

### Key AT Commands

| Command | Purpose | Example |
|---------|---------|---------|
| AT+CFUN | Power control | AT+CFUN=5 (off), AT+CFUN=1,1 (reset) |
| AT+CSIM | SIM APDU | AT+CSIM=14,"A0A4000002A000" |
| AT+STGR | STK response | AT+STGR=1,1 |
| AT+CGSN | Get IMEI | AT+CGSN |
| AT+CIMI | Get IMSI | AT+CIMI |
| AT+CCID | Get ICCID | AT+CCID |

### IMEI Manipulation

```bash
# actions/changeimei.sh
#!/bin/bash
DONGLE=$1
NEW_IMEI=$2

# Calculate NCK (unlock code)
# Type 1: MD5(IMEI + constant)
# Type 2: MD5(IMEI + different constant)

NCK=$(calculate_nck $NEW_IMEI)

# Send unlock command
asterisk -rx "dongle changeimei $DONGLE $NEW_IMEI"

# Verify
CURRENT_IMEI=$(asterisk -rx "dongle cmd $DONGLE AT+CGSN")
```

### USB Hub Power Control

```bash
# actions/repower.sh
#!/bin/bash
DONGLE=$1

# Power off USB port
sudo hub-ctrl -b 001 -d 001 -P 01 -p 0

sleep 2

# Power on USB port
sudo hub-ctrl -b 001 -d 001 -P 01 -p 1

# Wait for device to reinitialize
sleep 5
```

### State Files per Dongle

```
/var/svistok/dongles/state/$dongle.imsi       # Current IMSI
/var/svistok/dongles/state/$dongle.iccid      # Current ICCID
/var/svistok/dongles/state/$dongle.str_state  # State string (PIN, etc.)
/var/svistok/dongles/state/$dongle.imei       # Current IMEI
/var/svistok/dongles/log/$dongle.log          # Dongle logs
```

### Interface Definitions

#### AT Command API

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `send_at_cmd` | `$dongle`, `$cmd` | `string` | Send AT command via Asterisk |
| `change_imei` | `$dongle`, `$imei` | `bool` | Change dongle IMEI |
| `get_dongle_state` | `$dongle` | `array` | Get current state |
| `restart_dongle` | `$dongle` | `bool` | Restart via Asterisk |

#### Power Management API

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `power_cycle` | `$dongle` | `bool` | USB hub power cycle |
| `toggle_diag` | `$dongle` | `bool` | Toggle diagnostic mode |
| `calculate_nck` | `$imei`, `$type` | `string` | Calculate NCK code |

### Error Handling

```php
// modules/at.php
function send_at_cmd($dongle, $cmd) {
    $escaped_cmd = escapeshellarg($cmd);
    $output = shell_exec(
        "asterisk -rx \"dongle cmd $dongle $escaped_cmd\" 2>&1"
    );
    
    if (strpos($output, "ERROR") !== false) {
        error_log("AT command failed for $dongle: $cmd");
        return null;
    }
    
    return trim($output);
}

function power_cycle($dongle) {
    // Hub-ctrl can fail if hub not found
    $result = shell_exec(
        "sudo hub-ctrl -b 001 -d 001 -P 01 -p 0 2>&1"
    );
    
    if (strpos($result, "error") !== false) {
        error_log("Power cycle failed for $dongle: $result");
        return false;
    }
    
    sleep(2);
    shell_exec("sudo hub-ctrl -b 001 -d 001 -P 01 -p 1");
    sleep(5);
    
    return true;
}
```

### Security Considerations

- IMEI changing may violate local regulations
- Commands executed via sudo (requires proper permissions)
- No authentication for dongle control operations
- Diagnostic mode can expose sensitive information

---

## 03. Implementation Plan

### Phase 1: AT Command Interface

- [ ] Review modules/at.php implementation
- [ ] Test AT command execution for all supported modems
- [ ] Add error handling for failed commands

### Phase 2: Power Management

- [ ] Test USB hub power cycling
- [ ] Implement diagnostic mode toggle
- [ ] Add NCK calculation for all modem types

### Phase 3: Testing

- [ ] Test IMEI changing on E1550, E173, E303
- [ ] Test power cycle recovery
- [ ] Test error scenarios (hub not found, command timeout)

---

## 04. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [ADR-002](../adr-002-imsi-centric-model/): IMSI-Centric Data Model
- [SDD: Core Infrastructure](../sdd-core-infrastructure/): Base configuration
- [SDD: SIM Management](../sdd-sim-management/): SIM card lifecycle

---

*Generated by /legacy analysis - 2026-03-03*
