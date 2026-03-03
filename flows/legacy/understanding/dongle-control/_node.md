# Understanding: Dongle Control

> USB GSM modem (dongle) management, AT commands, power control, and IMEI manipulation

## Phase: EXPLORING

## Hypothesis

Dongle control manages the physical USB GSM modems including device initialization, AT command execution, power cycling, IMEI changing, and diagnostic mode operations.

## Sources

> Files/directories that inform this understanding

- `modules/at.php` - AT command execution wrapper
- `actions/donglerestart.sh` - Restart dongle via Asterisk
- `actions/changeimei.sh` - IMEI modification
- `actions/diagmode.sh` - Diagnostic mode toggle
- `system/repower.php` - USB hub power cycling
- `programmator/*.sh` - Mode switching and firmware
- `www/simbox/dongle.php` - Web interface for dongle management
- `svistok-aa/` - chan_dongle Asterisk module (C source)

## Validated Understanding

### Device Types

Primary support for Huawei USB modems (0x12d1 vendor ID):
- E1550
- E173
- E303/E353 series

### Control Mechanisms

1. **Asterisk Channel Driver** (`chan_dongle`):
   - Custom Asterisk module in `svistok-aa/`
   - Provides dongle commands via CLI/AMI
   - Handles GSM protocol and call routing

2. **AT Command Interface**:
   - Via Asterisk: `asterisk -rx 'dongle cmd <dongle> <AT command>'`
   - Commands include: CFUN (power), CSIM (SIM APDU), STK (toolkit)

3. **USB Hub Power Control**:
   - `hub-ctrl` utility for USB port power cycling
   - Targets Terminus hubs
   - Used for hard reset of modems

4. **USB Mode Switching**:
   - `usb_modeswitch` for Huawei device initialization
   - Converts from storage mode to modem mode
   - Multiple product IDs supported (1003, 14ac, 1446, etc.)

### Key Operations

| Action | Method | Command |
|--------|--------|---------|
| Restart modem | Asterisk | `dongle restart now <dongle>` |
| Change IMEI | Asterisk | `dongle changeimei <dongle> <imei>` |
| Power off | AT | `AT+CFUN=5` |
| Power on/reset | AT | `AT+CFUN=1,1` |
| SIM APDU | AT | `AT+CSIM=<len>,"<apdu>"` |
| Diagnostic mode | Action | `diagmode.sh` |

### IMEI Manipulation

The system includes IMEI modification capabilities:
- Direct IMEI change via Asterisk command
- NCK (unlock code) calculation using MD5-based algorithm
- Supports multiple modem types (Type 1 and Type 2 constants)

### State Files per Dongle

```
/var/svistok/dongles/state/$dongle.imsi      # Current IMSI
/var/svistok/dongles/state/$dongle.iccid     # Current ICCID
/var/svistok/dongles/state/$dongle.str_state # State string (PIN, etc.)
/var/svistok/dongles/log/                    # Dongle logs
```

### Integration Points

- **Asterisk**: Primary control interface
- **SIM Management**: KI programming uses dongle for AT commands
- **Automation**: Cron jobs monitor and manage dongles

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| - | Leaf node - no further children | N/A |

## Dependencies

- **Uses**: core-infrastructure (paths, utilities)
- **Used by**: sim-management, call-engine, automation

## Key Insights

1. **Huawei-specific**: Primary support for Huawei USB modems
2. **IMEI changing**: Built-in capability for IMEI manipulation
3. **USB hub control**: Hardware-level power management
4. **Custom Asterisk module**: chan_dongle for GSM integration

## ADR Candidates

- **ADR: chan_dongle Module** - Use of custom Asterisk channel driver
- **ADR: USB Hub Power Control** - Hardware power cycling strategy

## Flow Recommendation

- **Type**: SDD
- **Confidence**: high
- **Rationale**: Internal hardware control, no stakeholder-facing components

## Synthesis

Dongle control provides:
1. USB modem initialization and mode switching
2. AT command execution via Asterisk
3. IMEI modification capability
4. Power cycling via USB hubs
5. State tracking per device

## Bubble Up

> Summary to pass to parent during EXITING

- Huawei USB modem support (E1550, E173)
- IMEI changing capability
- chan_dongle Asterisk module for GSM
- USB hub power control for hard reset
- AT command interface for SIM/modem operations

---

*Phase: EXPLORING | Depth: 1 | Parent: / (root)*
