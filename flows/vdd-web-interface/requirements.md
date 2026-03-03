# VDD: Web Interface (SimBox Admin Panel)

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Visual-Driven Development  
**Module**: Web Interface

---

## 01. Requirements

### Overview

The SimBox web interface provides an administrative panel for managing GSM modems, SIM cards, call routing, and billing operations.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Display SIM card status and statistics | HIGH |
| FR-02 | Display dongle (USB modem) status and diagnostics | HIGH |
| FR-03 | Execute AT commands on selected modems | HIGH |
| FR-04 | Program KI credentials for multi-SIM adapters | HIGH |
| FR-05 | Send USSD/SMS commands | HIGH |
| FR-06 | Manage call plans and routing groups | HIGH |
| FR-07 | View billing statistics | MEDIUM |
| FR-08 | Debug mode for diagnostics | MEDIUM |
| FR-09 | USB hub power management | MEDIUM |
| FR-10 | Firmware update capability | LOW |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Russian language interface |
| NFR-02 | jQuery-based UI with tooltips |
| NFR-03 | Real-time status updates via AJAX |
| NFR-04 | Responsive table layouts |
| NFR-05 | Icon-based status indicators |

### Constraints

- PHP 5.x compatible (legacy code)
- Direct file system access for state
- Commands executed via sudo
- No authentication visible in analyzed code

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Web Interface                         │
│                   www/simbox/                            │
│  ┌─────────────────────────────────────────────────────┐│
│  │  index.php (router)                                 ││
│  │    ┌─────────────────────────────────────────────┐  ││
│  │    │  head.php (header, utilities, JS/CSS)       │  ││
│  │    └─────────────────────────────────────────────┘  ││
│  │                                                     ││
│  │  Pages:                                             ││
│  │  ┌─────────┬─────────┬─────────┬─────────────────┐ ││
│  │  │ sim.php │ dongle. │ nabor.  │ plan.php        │ ││
│  │  │         │ php     │ php     │                 │ ││
│  │  ├─────────┼─────────┼─────────┼─────────────────┤ ││
│  │  │ bablo.  │ calls.  │ debug.  │ settings.php    │ ││
│  │  │ php     │ php     │ php     │                 │ ││
│  │  └─────────┴─────────┴─────────┴─────────────────┘ ││
│  │                                                     ││
│  │  modules/                                           ││
│  │  ┌────────────────────────────────────────────────┐││
│  │  │ html.php   - HTML helpers, status icons        │││
│  │  │ actions.php - Action handlers                  │││
│  │  │ sms_texts.php - SMS templates                  │││
│  │  └────────────────────────────────────────────────┘││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### Page Structure

| Page | Purpose | Key Features |
|------|---------|--------------|
| `index.php` | Router | Loads head.php + requested page |
| `sim.php` | SIM Management | Balance, KI programming, USSD/SMS |
| `dongle.php` | Dongle Management | AT commands, IMEI change, diagnostics |
| `nabor.php` | Command Sets | Carrier-specific USSD commands |
| `plan.php` | Call Plans | Routing plan configuration |
| `bablo.php` | Billing | Call statistics, cost calculation |
| `calls.php` | Call History | Call logs and recordings |
| `debug.php` | Diagnostics | System debug information |
| `hubs.php` | USB Hubs | Hub power management |
| `proc.php` | Processes | Running system processes |
| `upgrade.php` | Updates | System upgrade interface |

### UI Components

#### Status Icons (html.php)

```php
// Dongle model icons
html_dongle($model)  // E1550, E173 icons

// Power state icons
html_cfun($cfun)     // -1=unknown, 1=on, 5=off

// SIM state icons
html_simst($simst)   // SIM status indicators

// Signal strength icons
html_rssi($rssi)     // 0-31 signal bars

// Group status icons
html_group($group)   // Working, paused, blocked states

// Direction icons
html_napr($direction) // Carrier/region routing icons

// Call status icons
html_dialstatus($ds) // ANSWER, NOANSWER, BUSY

// Recognition type icons
html_recog_type($rt) // Voice recognition results
```

#### Navigation Menu

```html
<a href="?p=sim">Симки</a> ::
<a href="?p=dongle">Свистки (nm)</a> ::
<a href="?p=diagmode">Свистки (um)</a> ::
<a href="?p=hubs">Хабы</a> ::
<a href="?p=nabor">Наборы команд</a> ::
<a href="?p=plan">Планы</a> ::
<a href="?p=proc">Процессы</a> ::
<a href="?p=bablo">Биллинг</a> ::
<a href="?p=upgrade">Обновление</a> ::
<a href="?p=debug">Debug</a>
```

### Key Features

#### SIM Management (sim.php)

- **Multi-SIM Adapter Programming**: Type 9 (STK) and Type 16 (SuperSIM)
- **KI Rotation**: Automatic KI credential rotation
- **Balance Tracking**: Real-time balance display
- **USSD/SMS**: Send commands to SIMs
- **Group Management**: Assign routing groups
- **Export Functions**: Export numbers, billing data

#### Dongle Management (dongle.php)

- **Device Grid**: Table view of all modems
- **AT Commands**: Execute custom AT commands
- **IMEI Management**: Change IMEI, blacklist
- **Power Control**: Power on/off, restart
- **Mode Selection**: GSM/WCDMA mode
- **Signal Monitoring**: RSSI, SNR, cell info
- **Diagnostic Mode**: Firmware flash mode

#### Billing (bablo.php)

- **Call Statistics**: Minutes per direction
- **Cost Calculation**: Per-carrier pricing
- **Direction Icons**: Visual carrier/region indicators
- **Total Summary**: Aggregate statistics

### Visual Design

#### Color Scheme

```css
table {
    border: 1px solid blue;
    border-collapse: collapse;
}
.header {
    background-color: #eeeeff;
}
.zebra {
    background-color: #eeeeff;
}
```

#### Tooltip System

Custom AJAX-powered tooltips:
- SIM logs on hover
- Call history tooltips
- Cell tower information

```javascript
function tooltip(thetooltip) {
    t = document.getElementById('tooltip');
    Ajax(thetooltip);
    t.style.display = 'block';
}
```

#### Icon Library

```
imgs/
├── dongle.png, dongle1550.ico, dongle173.ico
├── p-on.png, p-off.png (power states)
├── state/ (various status icons)
├── rssi/ (signal strength 0-4)
├── napravleine/ (carrier direction icons)
├── recog_types/ (voice recognition results)
└── play.png, pause.png, sleep.png (group states)
```

### Data Flow

```
User Action (Form Submit)
        │
        ▼
┌───────────────────┐
│   Page Handler    │
│   (sim.php,       │
│   dongle.php)     │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  exec_delay()     │
│  exec_s()         │
│  (head.php)       │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  Shell Script     │
│  (/usr/simbox/    │
│   actions/)       │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  Asterisk CLI     │
│  (dongle cmd)     │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│  State Files      │
│  (/var/svistok/)  │
└───────────────────┘
```

### Security Considerations

- **No visible authentication**: No login form in analyzed code
- **Sudo execution**: Commands run with elevated privileges
- **Direct file access**: State files readable/writable by web server
- **No input sanitization**: Limited escaping on user input
- **AJAX endpoints**: showlog.php returns system logs

---

## 03. Visual Mockups

### Main Dashboard (sim.php)

```
┌─────────────────────────────────────────────────────────────┐
│ [hostname] [server_name] SimBox  [version]                  │
│                                        [date] [uptime]      │
├─────────────────────────────────────────────────────────────┤
│ Симки :: Свистки (nm) :: Свистки (um) :: Хабы :: ...       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Checkbox] [Icon] [State] [Balance] [Number] [Group]      │
│  ☐          [📶]   OK    150.50  +7...   [🟢Work]         │
│  ☐          [📶]   PIN   50.00   +7...   [🟡Reserve]       │
│  ☐          [⚠️]   Block 0.00    +7...   [🔴Blocked]       │
│                                                             │
│  [Refresh] [Get Balance] [Send USSD] [Send SMS]            │
│  [Set KI] [New KI] [Rotate KI] [Export]                    │
└─────────────────────────────────────────────────────────────┘
```

### Dongle Management (dongle.php)

```
┌─────────────────────────────────────────────────────────────┐
│ Свистки (normal mode)                                       │
├─────────────────────────────────────────────────────────────┤
│ [☐] [📶E1550] [⚡] [SIM] [State] dongle01 [🔒] [RSSI]      │
│ [☐] [📶E173] [⚡] [SIM] [State] dongle02 [🔒] [RSSI]      │
│                                                             │
│ Actions:                                                    │
│ [Change IMEI] [Blacklist IMEI] [To Diag Mode]              │
│ [Restart] [Power ON] [Power OFF]                           │
│ [AT Command: __________] [Execute]                         │
│ [Mode: GSM ▼] [WCDMA ▼] [Freq Lock: __]                    │
└─────────────────────────────────────────────────────────────┘
```

### Billing (bablo.php)

```
┌─────────────────────────────────────────────────────────────┐
│ Биллинг                                                     │
├────────────┬──────────────┬─────────┬──────────┤
│ Date       │ Direction    │ Minutes │ Cost     │
├────────────┼──────────────┼─────────┼──────────┤
│ 01.03.2026 │ [🟦Bee SPb]  │ 125.5   │ 2.51     │
│ 01.03.2026 │ [🟩Meg Msk]  │ 85.2    │ 1.28     │
│ 01.03.2026 │ [🟥MTS SPb]  │ 45.0    │ 0.90     │
├────────────┼──────────────┼─────────┼──────────┤
│ Total      │              │ 255.7   │ 4.69     │
└────────────┴──────────────┴─────────┴──────────┘
```

---

## 04. Implementation Plan

### Phase 1: Review Current UI

- [ ] Audit all page templates
- [ ] Document icon library
- [ ] Map action handlers

### Phase 2: Security Improvements

- [ ] Add authentication layer
- [ ] Implement CSRF protection
- [ ] Add input validation
- [ ] Review sudo permissions

### Phase 3: Modernization

- [ ] Migrate to modern PHP (7.x/8.x)
- [ ] Replace jQuery with modern framework
- [ ] Add responsive design
- [ ] Implement WebSocket for real-time updates

---

## 05. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [ADR-002](../adr-002-imsi-centric-model/): IMSI-Centric Data Model
- [SDD: Core Infrastructure](../sdd-core-infrastructure/): Base configuration
- [SDD: SIM Management](../sdd-sim-management/): SIM card lifecycle
- [SDD: Dongle Control](../sdd-dongle-control/): USB modem management

---

*Generated by /legacy analysis - 2026-03-03*
