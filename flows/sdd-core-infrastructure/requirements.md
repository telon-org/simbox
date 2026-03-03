# SDD: Core Infrastructure

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Spec-Driven Development  
**Module**: Core Infrastructure

---

## 01. Requirements

### Overview

Core infrastructure provides foundational configuration and shared utilities for all Simbox modules.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Define system-wide path constants | HIGH |
| FR-02 | Provide shell configuration for all scripts | HIGH |
| FR-03 | Provide PHP configuration for web interface | HIGH |
| FR-04 | Implement utility functions for file operations | HIGH |
| FR-05 | Implement utility functions for command execution | HIGH |
| FR-06 | Support random delay execution (anti-detection) | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Configuration accessible from both Shell and PHP |
| NFR-02 | Path definitions consistent across languages |
| NFR-03 | Utility functions handle errors gracefully |
| NFR-04 | No external dependencies required |

### Constraints

- Must work with existing Asterisk installation
- Must support both CLI and web contexts
- Russian language UI labels

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Application Layer                   │
│  (SIM Mgmt, Dongle Control, Carrier Parsers, etc.)  │
├─────────────────────────────────────────────────────┤
│              Core Infrastructure Layer               │
│  ┌──────────────────┬─────────────────────────────┐ │
│  │  Shell Config    │      PHP Config             │ │
│  │  (config.sh)     │      (head.php)             │ │
│  ├──────────────────┼─────────────────────────────┤ │
│  │  Path Constants  │      Utility Functions      │ │
│  │  - ASTERISK      │      - file_get_contents_   │ │
│  │  - Dongle paths  │        def()                │ │
│  │  - SIM paths     │      - exec_s()             │ │
│  │  - State dirs    │      - exec_fon()           │ │
│  │                  │      - exec_delay()         │ │
│  └──────────────────┴─────────────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Directory Structure

```
/var/svistok/           # Runtime state (dongle-centric)
├── dongles/
│   └── state/          # Dongle states (.imsi, .iccid, .str_state)
├── sim/
│   ├── state/          # SIM state files (.dongle mapping)
│   ├── settings/       # SIM configuration
│   ├── statistics/     # Balance, call stats
│   └── limits/         # SIM limits
└── lists/              # Lists (dongles.list, imsi.list)

/var/simbox/            # Application data (SIM-centric)
├── sim/
│   ├── state/
│   ├── settings/
│   └── statistics/
└── plan/               # Calling plans

/usr/simbox/            # Application code
├── config.sh           # Shell configuration
├── system/             # Core scripts
├── actions/            # Action scripts
├── modules/            # PHP modules
└── www/simbox/         # Web interface
    ├── head.php        # PHP configuration
    └── modules/        # Web modules
```

### Configuration Files

#### config.sh (Shell)

```bash
#!/bin/bash
# Core path definitions for shell scripts

ASTERISK="asterisk"
MAKECALL="/usr/bin/makecall"

# Dongle paths
DONGLES_DIR="/var/svistok/dongles"
DONGLE_STATE_DIR="/var/svistok/dongles/state"

# SIM paths
SIM_DIR="/var/svistok/sim"
SIM_STATE_DIR="/var/svistok/sim/state"
SIM_SETTINGS_DIR="/var/svistok/sim/settings"
SIM_STATISTICS_DIR="/var/svistok/sim/statistics"
SIM_LIMITS_DIR="/var/svistok/sim/limits"

# Lists
LISTS_DIR="/var/svistok/lists"
DONGLES_LIST="/var/svistok/lists/dongles.list"
IMSI_LIST="/var/svistok/lists/imsi.list"

# Application paths
APP_DIR="/usr/simbox"
SYSTEM_DIR="/usr/simbox/system"
ACTIONS_DIR="/usr/simbox/actions"
```

#### head.php (PHP)

```php
<?php
// Core path definitions for PHP

// State directories
$SVISTOK_DIR = "/var/svistok";
$DONGLE_STATE_DIR = "/var/svistok/dongles/state";
$SIM_STATE_DIR = "/var/svistok/sim/state";
$SIM_SETTINGS_DIR = "/var/svistok/sim/settings";
$SIM_STATISTICS_DIR = "/var/svistok/sim/statistics";
$SIM_LIMITS_DIR = "/var/svistok/sim/limits";

// Application directories
$SIMBOX_DIR = "/var/simbox";
$SIMBOX_SIM_DIR = "/var/simbox/sim";
$PLAN_DIR = "/var/simbox/plan";

// Utility functions
function file_get_contents_def($file, $default = '') {
    if (file_exists($file)) {
        return trim(file_get_contents($file));
    }
    return $default;
}

function exec_s($cmd) {
    // Execute with sudo
    return shell_exec("sudo " . escapeshellcmd($cmd));
}

function exec_fon($cmd) {
    // Execute in background
    exec("nohup " . escapeshellcmd($cmd) . " > /dev/null 2>&1 &");
}

function exec_delay($cmd, $max_delay = 30) {
    // Execute with random delay (anti-detection)
    $delay = rand(0, $max_delay);
    sleep($delay);
    return exec_s($cmd);
}
?>
```

### Interface Definitions

#### File Operations API

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `file_get_contents_def` | `$file`, `$default` | `string` | Read file with default value |
| `file_put_contents_safe` | `$file`, `$content` | `bool` | Atomic write via temp file |
| `file_exists_def` | `$file` | `bool` | Check file existence |

#### Command Execution API

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `exec_s` | `$cmd` | `string` | Execute command with sudo |
| `exec_fon` | `$cmd` | `void` | Execute in background |
| `exec_delay` | `$cmd`, `$max_delay` | `string` | Execute with random delay |

### Error Handling

```php
// File read errors return default value
$balance = file_get_contents_def($file, "0");

// Command execution errors logged
function exec_s($cmd) {
    $result = shell_exec("sudo " . escapeshellcmd($cmd) . " 2>&1");
    if ($result === null) {
        error_log("Command failed: $cmd");
        return "";
    }
    return $result;
}
```

### Security Considerations

- Commands executed via `sudo` (requires proper sudoers config)
- No input sanitization on file paths (caller responsibility)
- Random delay for anti-detection (USSD/SMS commands)

---

## 03. Implementation Plan

### Phase 1: Configuration

- [ ] Review config.sh path definitions
- [ ] Review head.php path definitions
- [ ] Ensure consistency between Shell and PHP

### Phase 2: Utility Functions

- [ ] Audit existing utility functions
- [ ] Add error handling where missing
- [ ] Document function signatures

### Phase 3: Testing

- [ ] Test path resolution in both contexts
- [ ] Test utility functions with edge cases
- [ ] Verify sudo permissions

---

## 04. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [SDD: SIM Management](../sdd-sim-management/): SIM card lifecycle
- [SDD: Dongle Control](../sdd-dongle-control/): USB modem management

---

*Generated by /legacy analysis - 2026-03-03*
