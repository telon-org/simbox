# Understanding: Project Root

> Entry point for recursive understanding. Children are top-level logical domains.

## Phase: SYNTHESIZING

## Project Overview

**Simbox** is a GSM SIM-box management system that integrates with Asterisk PBX to manage multiple GSM modems (dongles) for telephony operations. The system handles:

- **SIM Card Management**: Tracking SIM cards, their states, balances, tariffs, and phone numbers
- **GSM Modem Control**: Managing USB GSM dongles via AT commands through Asterisk's chan_dongle module
- **Call Routing**: Making outbound calls through GSM network via Asterisk dialplan
- **SMS/USSD Processing**: Sending/receiving SMS, parsing USSD responses for balance and tariff info
- **Voice Recognition**: Using Yandex SpeechKit for call recording transcription (IVR recognition)
- **Multi-Carrier Support**: Operator-specific parsers for Tele2, Beeline, MTS, MegaFon, Rostelekom, Velcom

### Technology Stack

- **Language**: PHP (primary), Shell scripts, Pascal (legacy components), C (Asterisk module)
- **PBX**: Asterisk 11/18 with chan_dongle module
- **Web Interface**: PHP-based admin panel (www/simbox/)
- **Storage**: File-based state storage in /var/simbox/ and /var/svistok/
- **External Services**: HTTP API to "simserver" for centralized stats

### Architecture Pattern

File-based state machine with:
- State files in `/var/svistok/` (dongle/SIM state)
- Configuration in `/var/simbox/` (settings, statistics)
- Cron-based automation
- Asterisk dialplan integration via .call files

## Identified Domains

> Logical domains discovered. Each becomes a child directory for deeper exploration.

| Domain | Hypothesis | Priority | Status |
|--------|------------|----------|--------|
| core-infrastructure | Base system config, paths, shell utilities | HIGH | PENDING |
| sim-management | SIM card state, balance, statistics tracking | HIGH | PENDING |
| dongle-control | USB modem management, AT commands, power control | HIGH | PENDING |
| carrier-parsers | Operator-specific USSD/SMS parsing (nabor/) | MEDIUM | PENDING |
| call-engine | Asterisk dialplan integration, call routing | HIGH | PENDING |
| voice-recognition | Speech-to-text for IVR navigation (ai/recog/) | MEDIUM | PENDING |
| automation | Cron jobs, autopilot, scheduled tasks | MEDIUM | PENDING |
| web-interface | Admin panel, API endpoints (www/) | MEDIUM | PENDING |
| chan-dongle | Asterisk channel driver (svistok-aa/) | LOW | PENDING |
| legacy-tools | Pascal programs, old utilities (wtss/, old/) | LOW | PENDING |

## Source Mapping

> Which source paths map to which logical domains

| Source Path | -> Domain |
|-------------|-----------|
| config.sh | core-infrastructure |
| modules/*.php | sim-management, dongle-control |
| system/*.sh, system/*.php | dongle-control, sim-management |
| nabor/*/parse/*.php | carrier-parsers |
| asterisk/, asterisk11/, asterisk18/ | call-engine |
| ai/recog/ | voice-recognition |
| ai/autopilot/, ai/sms/ | automation |
| cron/*.sh | automation |
| actions/*.sh | dongle-control |
| www/simbox/*.php | web-interface |
| svistok-aa/*.c | chan-dongle |
| wtss/*.pas | legacy-tools |
| programmator/*.sh | dongle-control |

## Cross-Cutting Concerns

> Things that span multiple domains (may become ADRs)

- **File-based State Management**: All state stored as flat files, no database
- **IMSI-centric Design**: IMSI (SIM identifier) is the primary key across all subsystems
- **Russian Language UI/Docs**: Interface and code comments in Russian
- **Security Concerns**: Yandex API key hardcoded, no input sanitization visible
- **Asterisk Integration Pattern**: .call files for outbound calls, AMI for commands
- **Multi-Asterisk Support**: Both Asterisk 11 and 18 versions maintained

## Children Spawned

```
core-infrastructure   DONE - Base config, paths, utilities
sim-management        DONE - KI programming, balance tracking
dongle-control        DONE - USB modem management, AT commands
carrier-parsers       DONE - Carrier USSD parsing (9 operators)
call-engine           DONE - Asterisk dialplan, zone routing
voice-recognition     SKIPPED - Specialized feature
automation            SKIPPED - Derivative (cron, autopilot)
web-interface         SKIPPED - UI layer
chan-dongle           SKIPPED - C source code
legacy-tools          SKIPPED - Pascal/old code
```

## Synthesis

> Combined insights from all analyzed children

### System Purpose

**Simbox** is a GSM SIM-box system designed for routing voice calls through multiple GSM modems. The architecture supports:

1. **Large-scale GSM termination**: Multiple USB modems managed by Asterisk PBX
2. **Multi-SIM adapters**: Programmable SIM cards with KI rotation
3. **Multi-carrier support**: 9 carriers across Russia, Ukraine, Belarus
4. **Anti-detection features**: IMEI changing, KI rotation, random delays
5. **Central management**: Stats and KI credentials via external server

### Architecture Summary

```
                     ┌─────────────────┐
                     │   simserver     │
                     │  (central mgmt) │
                     └────────┬────────┘
                              │ HTTP API
              ┌───────────────┼───────────────┐
              │               │               │
      ┌───────▼───────┐ ┌─────▼─────┐ ┌───────▼───────┐
      │ SIM Mgmt      │ │ Stats     │ │ KI Server     │
      │ (balance,etc) │ │ (calls)   │ │ (credentials) │
      └───────┬───────┘ └─────┬─────┘ └───────┬───────┘
              │               │               │
      ┌───────▼───────────────▼───────────────▼───────┐
      │                    Simbox                      │
      │  ┌──────────────────────────────────────────┐ │
      │  │              Asterisk PBX                │ │
      │  │         (chan_dongle module)             │ │
      │  └──────────────────┬───────────────────────┘ │
      │                     │                         │
      │  ┌──────────┬───────┴────────┬──────────┐    │
      │  │ Dongle 1 │   Dongle 2     │ Dongle N │    │
      │  │ (E1550)  │   (E173)       │  (...)   │    │
      │  └────┬─────┘   └────┬───────┘ └────┬───┘    │
      │       │              │              │        │
      │  ┌────▼────┐    ┌────▼────┐    ┌────▼────┐   │
      │  │Multi-SIM│    │Multi-SIM│    │Multi-SIM│   │
      │  │Adapter  │    │Adapter  │    │Adapter  │   │
      │  └─────────┘    └─────────┘    └─────────┘   │
      └──────────────────────────────────────────────┘
```

### Key Technical Decisions

1. **File-based state**: All state in /var/svistok/ and /var/simbox/ as flat files
2. **IMSI-centric model**: IMSI as primary key across all subsystems
3. **Asterisk integration**: chan_dongle for GSM, .call files for outbound
4. **Zone routing**: Region/carrier specific dialplan rules
5. **Multi-SIM adapters**: Type 9 (STK) and Type 16 (SuperSIM) support

### Recommended ADRs

| ADR | Topic | Type |
|-----|-------|------|
| ADR-001 | File-Based State Storage | Constraining |
| ADR-002 | IMSI-Centric Data Model | Constraining |
| ADR-003 | Multi-SIM Adapter Support | Enabling |
| ADR-004 | Zone-Based Call Routing | Enabling |
| ADR-005 | Central KI Management | Enabling |

---

*Created by /legacy ENTERING phase*
*Phase: EXPLORING | Depth: 0 | Parent: none*
