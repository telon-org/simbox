# Understanding: SIM Management

> SIM card lifecycle management including KI programming, balance tracking, and statistics

## Phase: EXPLORING

## Hypothesis

SIM management handles the complete lifecycle of SIM cards in the system, including programming cryptographic keys (KI), tracking balance and statistics, and managing SIM state.

## Sources

> Files/directories that inform this understanding

- `modules/sim.php` - Core SIM functions (balance, stats upload)
- `modules/ki.php` - KI programming functions for multi-SIM adapters
- `system/set_ki.php` - KI programming script
- `system/new_ki.php` - New KI retrieval from central server
- `readers/upload_*.php` - KI upload to central server
- `www/simbox/sim.php` - Web interface for SIM management

## Validated Understanding

### SIM Card Lifecycle

1. **KI Provisioning**: SIM cards (multi-SIM adapters) are programmed with:
   - KI (cryptographic key) - 32 hex chars
   - IMSI (subscriber identity) - 18 chars
   - ICCID (card identifier) - 20 chars
   - SMSC (SMS center) - 24 chars
   - Associated IMEI for the modem

2. **Adapter Types**:
   - Type 9: "9th generation" - Uses STK (SIM Toolkit) AT commands
   - Type 16: "SuperSIM 16th generation" - Uses CSIM APDU commands

3. **Central Server Integration**:
   - Fetches new KI credentials from `simserver:8122`
   - Uploads balance, tariff, number to central server
   - KI rotation for anti-detection

### Key Functions

From `modules/sim.php`:
- `save_balance($imsi, $balance)` - Persist balance locally
- `upload_balance($imsi, $balance)` - Sync to central server
- `upload_tarif($imsi, $tarif)` - Sync tariff info
- `upload_number($imsi, $number)` - Sync phone number
- `upload_op($imsi, $op_t, $op_d)` - Sync operator info

### State Files per SIM (by IMSI)

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
```

### Multi-SIM Adapter Programming

The system supports programmable multi-SIM adapters that can:
- Store multiple SIM profiles
- Be reprogrammed via AT commands
- Change IMEI dynamically
- Rotate credentials for fraud detection evasion

### Security/Purpose Analysis

The KI programming and rotation features, combined with:
- IMEI changing capability
- Balance tracking
- Carrier-specific parsers
- Random delay anti-detection

Suggests this system is designed for **SIM-box fraud operations** - routing calls through GSM networks while evading operator detection.

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| - | Leaf node - no further children | N/A |

## Dependencies

- **Uses**: core-infrastructure (paths, utilities)
- **Used by**: carrier-parsers, automation, web-interface

## Key Insights

1. **Centralized KI Management**: KI credentials fetched from external server
2. **Multi-SIM Adapters**: Support for programmable SIM cards
3. **IMSI as Primary Key**: All state indexed by IMSI
4. **Real-time Sync**: Balance/stats synced to central server

## ADR Candidates

- **ADR: Multi-SIM Adapter Support** - Decision to support programmable SIMs
- **ADR: Central KI Server** - Architecture for KI credential management
- **ADR: IMSI-Centric Data Model** - Using IMSI as primary identifier

## Flow Recommendation

- **Type**: SDD
- **Confidence**: high
- **Rationale**: Internal technical module, no stakeholder-facing documentation

## Synthesis

SIM management is a core module handling:
1. KI programming for multi-SIM adapters
2. Balance and statistics tracking
3. Central server synchronization
4. SIM lifecycle state management

## Bubble Up

> Summary to pass to parent during EXITING

- Multi-SIM adapter programming (KI, IMSI, ICCID, IMEI)
- Two adapter types: Type 9 (STK) and Type 16 (SuperSIM)
- Central server for KI provisioning and stats collection
- File-based state per IMSI

---

*Phase: EXPLORING | Depth: 1 | Parent: / (root)*
