# Understanding: Call Engine

> Asterisk dialplan integration for GSM call routing through SIM-box

## Phase: EXPLORING

## Hypothesis

The call engine provides Asterisk dialplan configuration for routing calls through GSM modems, including zone-based routing, call monitoring, and integration with the central server.

## Sources

> Files/directories that inform this understanding

- `asterisk/extensions/extensions_dial.conf` - Main dial logic
- `asterisk/extensions/extensions_incoming.conf` - Incoming call handling
- `asterisk/extensions/extensions_zones.conf` - Zone includes
- `asterisk/extensions/zones/*.conf` - Per-zone dial rules
- `system/makecall*.sh` - Outbound call generators

## Validated Understanding

### Dialplan Architecture

The system uses a hierarchical Asterisk dialplan structure:

1. **Core Extensions**: Main call handling logic
2. **Zone Extensions**: Region/carrier specific routing
3. **Special Modes**: VIP, MAY, MAG, NAV, etc.

### Key Dialplan Files

| File | Purpose |
|------|---------|
| `extensions_dial.conf` | Outbound call logic with special mode parsing |
| `extensions_incoming.conf` | Inbound call handling, server notification |
| `extensions_zones.conf` | Includes for regional routing rules |
| `extensions_monitor.conf` | Call recording/monitoring |
| `extensions_samsebe.conf` | Self-call testing |
| `extensions_captcha.conf` | Captcha/IVR handling |

### Zone-Based Routing

Zones are organized by carrier and region:
```
zones/
├── extensions_bee_spb.conf     # Beeline St. Petersburg
├── extensions_meg_spb.conf     # MegaFon St. Petersburg
├── extensions_mts_spb.conf     # MTS St. Petersburg
├── extensions_tele2_spb.conf   # Tele2 St. Petersburg
├── extensions_all_spb.conf     # All carriers SPb
├── extensions_kievstar_ua.conf # Kievstar Ukraine
└── ...
```

### Special Call Modes

The dialplan supports encoded special modes in the dialed number:
- `#SOU` - Sound/audio test mode
- `#PRE` - Pre-answer mode
- `#POS` - Post-answer mode
- `#MAY` - May mode (special routing)
- `#MAG` - Mag mode (special routing)
- `#VIP` - VIP priority routing
- `#NAV` - Navigation mode

### Call Flow

**Outbound (.call files)**:
```
1. Generate .call file with parameters
2. Move to /var/spool/asterisk/outgoing/
3. Asterisk processes and dials via chan_dongle
```

**Inbound (dialplan)**:
```
1. Call arrives on dongle
2. Context: default-dongle-incoming
3. Notify central server via HTTP
4. Process through macros (numberb-in-std, incoming-full)
```

### Central Server Integration

All calls notify the central server:
```
http://simserver:8122/in.php?numberb=...&numbermy=...&imei=...&imsi=...&dongle=...
```

### Call Recording

The system includes call recording:
- Pre-answer audio
- Post-answer audio
- Stored in `/var/spool/asterisk/monitor/`
- Converted to FLAC for archival

### Variables Used

| Variable | Description |
|----------|-------------|
| `numberb` | B-party number (destination) |
| `numbera` | A-party number (source) |
| `dongle` | Dongle identifier |
| `imsi` | SIM card IMSI |
| `qos` | Quality of service flag |
| `spec` | Special mode flag |
| `uid` | Unique call identifier |

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| - | Leaf node - no further children | N/A |

## Dependencies

- **Uses**: core-infrastructure (paths), dongle-control (chan_dongle)
- **Used by**: voice-recognition (call recordings)

## Key Insights

1. **Zone-based routing**: Calls routed based on destination region
2. **Central server notification**: All calls reported to simserver
3. **Call recording**: Full call recording infrastructure
4. **Special modes**: Encoded in dialed number suffix

## ADR Candidates

- **ADR: Zone-Based Routing** - Regional routing strategy
- **ADR: Call File Generation** - Using .call files for outbound

## Flow Recommendation

- **Type**: SDD
- **Confidence**: high
- **Rationale**: Internal call routing logic, no stakeholder documentation

## Synthesis

Call engine provides:
1. Asterisk dialplan for GSM call routing
2. Zone-based carrier/region routing
3. Special mode support for testing/VIP
4. Call recording and monitoring
5. Central server integration

## Bubble Up

> Summary to pass to parent during EXITING

- Asterisk dialplan-based call routing
- Zone files for regional carrier routing
- .call file generation for outbound calls
- Central server notification for all calls
- Full call recording infrastructure

---

*Phase: EXPLORING | Depth: 1 | Parent: / (root)*
