# SDD: Call Engine

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Spec-Driven Development  
**Module**: Call Engine

---

## 01. Requirements

### Overview

Call Engine provides Asterisk dialplan integration for GSM call routing through SIM-box, including zone-based routing, call monitoring, and central server integration.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Route outbound calls via GSM modems | HIGH |
| FR-02 | Support zone-based carrier/region routing | HIGH |
| FR-03 | Handle special routing modes (VIP, test, nav) | HIGH |
| FR-04 | Generate .call files for outbound calls | HIGH |
| FR-05 | Notify central server of all calls | HIGH |
| FR-06 | Record calls (pre/post answer) | HIGH |
| FR-07 | Handle incoming calls | MEDIUM |
| FR-08 | Support captcha/IVR navigation | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Integration with Asterisk chan_dongle |
| NFR-02 | Zone files organized by carrier/region |
| NFR-03 | Call recording in FLAC format |
| NFR-04 | Russian language prompts and UI |

### Constraints

- Requires Asterisk 11/18 with chan_dongle
- Central server (simserver:8122) must be available
- Call recordings stored in /var/spool/asterisk/monitor/

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Asterisk PBX                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │              Dialplan Configuration                 │ │
│  │  ┌────────────┬────────────┬─────────────────────┐ │ │
│  │  │ extensions │ extensions │ extensions_zones    │ │ │
│  │  │ _dial.conf │ _incoming  │ .conf               │ │ │
│  │  ├────────────┼────────────┼─────────────────────┤ │ │
│  │  │ Zone files │ Special    │ Call recording      │ │ │
│  │  │ (zones/)   │ modes      │ (monitor)           │ │ │
│  │  └────────────┴────────────┴─────────────────────┘ │ │
│  └────────────────────────────────────────────────────┘ │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │  Central Server │
              │  simserver:8122 │
              └─────────────────┘
```

### Dialplan File Structure

```
asterisk/extensions/
├── extensions_dial.conf         # Main outbound logic
├── extensions_incoming.conf     # Incoming call handling
├── extensions_zones.conf        # Zone includes
├── extensions_monitor.conf      # Call recording
├── extensions_samsebe.conf      # Self-call testing
├── extensions_captcha.conf      # Captcha/IVR
└── zones/
    ├── extensions_all_spb.conf      # All carriers SPb
    ├── extensions_bee_spb.conf      # Beeline SPb
    ├── extensions_meg_spb.conf      # MegaFon SPb
    ├── extensions_mts_spb.conf      # MTS SPb
    ├── extensions_tele2_spb.conf    # Tele2 SPb
    ├── extensions_rostel_spb.conf   # Rostelekom SPb
    ├── extensions_kievstar_ua.conf  # Kievstar Ukraine
    ├── extensions_velcom_by.conf    # Velcom Belarus
    └── extensions_life_by.conf      # Life Belarus
```

### Zone-Based Routing

Each zone file contains pattern-matched extensions:

```asterisk
; extensions_tele2_spb.conf
[extensions-tele2-spb]

; Local SPb numbers (812)
exten => _812XXXXXXX,!
    Set(DONGLE_GROUP=tele2_spb_work)
    Set(ROUTE_COST=1)
    Set(ZONE=spb)
    Goto(dial-via-gsm,1)

; Federal Russian numbers (8 XXXXXXXXXX)
exten => _8[2-9]XXXXXXXX,!
    Set(DONGLE_GROUP=tele2_federal)
    Set(ROUTE_COST=2)
    Set(ZONE=federal)
    Goto(dial-via-gsm,1)

; International numbers (+XX...)
exten => _+X.!
    Set(DONGLE_GROUP=tele2_intl)
    Set(ROUTE_COST=3)
    Set(ZONE=intl)
    Goto(dial-via-gsm,1)
```

### Special Routing Modes

Encoded as suffix in dialed number:

| Suffix | Mode | Behavior |
|--------|------|----------|
| `#SOU` | Sound | Audio test mode, plays tone |
| `#PRE` | Pre-answer | Pre-answer routing logic |
| `#POS` | Post-answer | Post-answer routing logic |
| `#MAY` | May | Special routing (MAY mode) |
| `#MAG` | Mag | Special routing (MAG mode) |
| `#VIP` | VIP | Priority routing, any SIM |
| `#NAV` | Nav | Navigation/IVR mode |

### Mode Parsing (extensions_dial.conf)

```asterisk
; Extract special mode from dialed number
; e.g., +79991234567#VIP -> number=+79991234567, mode=VIP

exten => _X.#*,1
    Set(NUMBER=${EXTEN})
    Set(MODE=${CUT(EXTEN,#,2)})
    
    GotoIf($["${MODE}" = "VIP"]?vip-routing)
    GotoIf($["${MODE}" = "SOU"]?sound-test)
    GotoIf($["${MODE}" = "NAV"]?nav-mode)
    ; ... other modes
    
    ; Normal routing
    Goto(zone-routing,1)
```

### .call File Generation

```bash
# system/makecall.sh
#!/bin/bash
DONGLE=$1
NUMBER=$2
IMSI=$3

CALLFILE="/var/spool/asterisk/outgoing/call.$$"

cat > "$CALLFILE" << EOF
Channel: Dongle/$DONGLE/$NUMBER
MaxRetries: 0
RetryTime: 60
WaitTime: 45
Context: default-dongle-outgoing
Extension: s
Priority: 1
Set: IMSI=$IMSI
Set: DONGLE=$DONGLE
EOF

# Trigger call
mv "$CALLFILE" /var/spool/asterisk/outgoing/
```

### Central Server Notification

```asterisk
; extensions_incoming.conf
; Notify central server on incoming call

exten => s,n,
    System(
        curl -s \
        "http://simserver:8122/in.php?
        numberb=${NUMBERB}&
        numbermy=${NUMBERMY}&
        imei=${IMEI}&
        imsi=${IMSI}&
        dongle=${DONGLE}&
        uid=${UNIQUEID}"
    )
```

### Call Recording

```asterisk
; extensions_monitor.conf
; Record calls to FLAC format

[call-recording]
exten => s,1,
    Set(RECORD_PATH=/var/spool/asterisk/monitor/${UNIQUEID})
    Set(RECORD_FILE=${RECORD_PATH}.wav)
    
    ; Start recording
    Monitor(wav,${RECORD_FILE},m)
    
    ; After call ends, convert to FLAC
    same => n,Hangup()
    
exten => h,1,
    System(
        flac -s ${RECORD_FILE} -o ${RECORD_PATH}.flac &&
        rm ${RECORD_FILE}
    )
```

### Variables Used

| Variable | Description | Source |
|----------|-------------|--------|
| `NUMBERB` | B-party number (destination) | Dialed number |
| `NUMBERA` | A-party number (source) | Caller ID |
| `NUMBERMY` | Our number (SIM number) | SIM settings |
| `DONGLE` | Dongle identifier | Channel |
| `IMSI` | SIM card IMSI | Dongle state |
| `IMEI` | Modem IMEI | Dongle info |
| `QOS` | Quality of service flag | Input |
| `SPEC` | Special mode flag | Input |
| `UID` | Unique call identifier | UNIQUEID |
| `ZONE` | Routing zone | Zone file |
| `DONGLE_GROUP` | SIM group for routing | Zone file |
| `ROUTE_COST` | Route cost/priority | Zone file |

### Interface Definitions

#### Dialplan Macros

| Macro | Parameters | Description |
|-------|------------|-------------|
| `dial-via-gsm` | None | Place call via chan_dongle |
| `notify-server` | `$numberb`, `$numbermy` | HTTP notification |
| `start-recording` | None | Begin call recording |
| `zone-select` | `$destination` | Select routing zone |

### Error Handling

```asterisk
; extensions_dial.conf
; Handle call failures

exten => s,n,
    Dial(Dongle/${DONGLE}/${NUMBER},30)
    
    ; Check result
    same => n,GotoIf($["${DIALSTATUS}" = "ANSWER"]?success)
    same => n,GotoIf($["${DIALSTATUS}" = "BUSY"]?busy)
    same => n,GotoIf($["${DIALSTATUS}" = "NOANSWER"]?no-answer)
    same => n,GotoIf($["${DIALSTATUS}" = "CHANUNAVAIL"]?chan-unavail)
    
    ; Retry with different SIM
    same => n,Set(FAIL_COUNT=${INC(FAIL_COUNT)})
    same => n,GotoIf($[${FAIL_COUNT} < 3]?retry)
    
    ; All retries failed
    same => n,Playback(all-circuits-busy)
    same => n,Hangup()
```

### Security Considerations

- .call files writable by application user
- No authentication for server notifications
- Call recordings contain sensitive conversations
- HTTP (not HTTPS) for server communication

---

## 03. Implementation Plan

### Phase 1: Dialplan Review

- [ ] Audit extensions_dial.conf logic
- [ ] Review all zone files for consistency
- [ ] Test special mode parsing

### Phase 2: Call Recording

- [ ] Verify recording configuration
- [ ] Test FLAC conversion
- [ ] Check storage management

### Phase 3: Testing

- [ ] Test zone routing for all carriers
- [ ] Test special modes (VIP, SOU, NAV)
- [ ] Test central server notification
- [ ] Test call recording pipeline

---

## 04. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [ADR-002](../adr-002-imsi-centric-model/): IMSI-Centric Data Model
- [ADR-004](../adr-004-zone-routing/): Zone-Based Call Routing
- [ADR-005](../adr-005-central-ki/): Central KI Management
- [SDD: Dongle Control](../sdd-dongle-control/): USB modem management

---

*Generated by /legacy analysis - 2026-03-03*
