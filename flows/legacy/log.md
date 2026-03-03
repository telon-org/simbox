# Legacy Analysis Log

## Session History

### 2026-03-03 - AI & Automation Analysis Complete

**Mode**: BFS (continued)
**Target**: /Users/anton/proj/telon/simbox/ai

**Generated**:
- **SDD: AI & Automation** - Intelligent automation documentation
  - Voice recognition (Yandex SpeechKit)
  - Autopilot (automated PIN entry, carrier-specific rules)
  - SMS automation (balance requests, spam)
  - Auto-blocking (high DATT, low ACDL detection)
  - Watchdog (Asterisk monitoring, auto-reboot)
  - Samsebe (self-test calls)

**Total Flows Created**: 13
- ADRs: 5
- SDDs: 6
- VDDs: 1
- DDDs: 1

---

### 2026-03-03 - Web Interface & Billing Analysis Complete

**Mode**: BFS (continued)
**Target**: /Users/anton/proj/telon/simbox/www

**Generated**:
- **VDD: Web Interface** - Admin panel documentation
  - 11 pages (sim.php, dongle.php, nabor.php, plan.php, bablo.php, etc.)
  - jQuery-based UI with custom tooltips
  - Russian language interface
  - Icon-based status indicators
  
- **DDD: Billing System** - Stakeholder-facing billing documentation
  - Per-carrier rate cards
  - Mass payment export
  - Daily summary reports
  - Balance alerts

**Total Flows Created**: 12
- ADRs: 5
- SDDs: 5
- VDDs: 1
- DDDs: 1

---

### 2026-03-03 - Flow Generation Complete

**Mode**: BFS
**Target**: /Users/anton/proj/telon/simbox (project root)

**Generated ADRs**:
- ADR-001: File-Based State Storage (Constraining)
- ADR-002: IMSI-Centric Data Model (Constraining)
- ADR-003: Multi-SIM Adapter Support (Enabling)
- ADR-004: Zone-Based Call Routing (Enabling)
- ADR-005: Central KI Management (Enabling)

**Generated SDDs**:
- SDD: Core Infrastructure - Base config, paths, utilities
- SDD: SIM Management - KI programming, balance tracking
- SDD: Dongle Control - USB modem management, AT commands
- SDD: Carrier Parsers - 9 carriers, USSD parsing
- SDD: Call Engine - Asterisk dialplan, zone routing

**All flows created in DRAFT status**

---

### 2026-03-03 - Core Analysis Complete

**Mode**: BFS
**Target**: /Users/anton/proj/telon/simbox (project root)

**Analyzed**:
- **core-infrastructure**: File-based config (config.sh), path definitions, utility functions
- **sim-management**: KI programming for multi-SIM adapters (Type 9 STK, Type 16 SuperSIM), balance tracking, central server sync
- **dongle-control**: USB modem management, AT commands via Asterisk chan_dongle, IMEI manipulation, USB hub power control
- **carrier-parsers**: 9 carriers (Tele2, Beeline, MegaFon, MTS, Rostelekom, Kievstar, Velcom, Life), USSD parsing
- **call-engine**: Asterisk dialplan, zone-based routing, .call file generation, call recording

**Key Findings**:
- System is a GSM SIM-box for call routing through GSM network
- Supports multi-SIM adapters with KI/IMSI/ICCID/IMEI rotation
- File-based state storage (no database)
- Central server (simserver:8122) for KI management and statistics
- Anti-detection features (IMEI changing, KI rotation, random delays)

**Skipped** (lower priority):
- chan-dongle (C source), legacy-tools (Pascal)

---

### 2026-03-03 - Initialization

**Mode**: BFS
**Target**: /Users/anton/proj/telon/simbox (project root)

**Actions**:
- Initialized legacy workspace from templates
- Created understanding tree root
- Beginning project analysis

---

*Append new entries at the top.*
