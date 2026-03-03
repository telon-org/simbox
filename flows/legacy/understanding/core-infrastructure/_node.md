# Understanding: Core Infrastructure

> Base system configuration, paths, and common utilities

## Phase: EXPLORING

## Hypothesis

Core infrastructure provides the foundational configuration and shared utilities used across all other modules in the Simbox system.

## Sources

> Files/directories that inform this understanding

- `config.sh` - Shell configuration with path definitions
- `www/simbox/head.php` - PHP configuration, path definitions, utility functions
- `www/simbox/modules/html.php` - HTML rendering helpers
- `system/get_args.sh` - Argument parsing utility

## Validated Understanding

### Configuration Architecture

The system uses two parallel configuration approaches:

1. **Shell Configuration** (`config.sh`):
   - Defines executable paths (ASTERISK, MAKECALL scripts)
   - Directory paths for dongles, SIM state, settings
   - Uses environment variables for system-wide access

2. **PHP Configuration** (`www/simbox/head.php`):
   - Defines same paths as PHP variables
   - Provides utility functions for file operations
   - Sets up web interface layout and JavaScript

### Key Directory Structure

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

/usr/simbox/            # Application code (this project)
├── system/             # Core scripts
├── actions/            # Action scripts
├── nabor/              # Carrier-specific parsers
└── www/                # Web interface
```

### Core Utility Functions

From `head.php`:
- `file_get_contents_def($file, $default)` - Read file with default
- `exec_s($cmd)` - Execute command with sudo
- `exec_fon($cmd)` - Execute in background
- `exec_delay($cmd)` - Execute with optional random delay (anti-detection)

### Security Observations

- Commands executed via `sudo` without sanitization
- No input validation on file paths
- Random delay feature suggests anti-fraud-detection measures

## Children Identified

> Deeper concepts spawned during SPAWNING phase

| Child | Hypothesis | Status |
|-------|------------|--------|
| - | Core infrastructure is a leaf node | N/A |

## Dependencies

- **Uses**: None (foundational layer)
- **Used by**: All other modules

## Key Insights

1. **Dual path storage**: svistok (dongle-centric) vs simbox (SIM-centric)
2. **File-based state**: No database, all state in flat files
3. **Russian UI**: Interface labels in Russian
4. **Anti-detection**: Random delays for USSD/SMS commands

## ADR Candidates

- **ADR: File-Based State Storage** - Decision to use filesystem instead of database
- **ADR: Dual-Centric Data Model** - svistok (dongle) vs simbox (SIM) separation

## Flow Recommendation

- **Type**: SDD
- **Confidence**: high
- **Rationale**: Internal infrastructure, no stakeholder-facing components

## Synthesis

> Updated during SYNTHESIZING phase after children complete

Core infrastructure provides:
1. Path constants for file-based state storage
2. Utility functions for command execution
3. Web interface framework
4. No children - this is a foundational leaf node

## Bubble Up

> Summary to pass to parent during EXITING

- File-based state storage in /var/svistok/ and /var/simbox/
- Dual data model: dongle-centric (svistok) and SIM-centric (simbox)
- PHP/Shell hybrid architecture
- Utility functions shared across modules

---

*Phase: EXPLORING | Depth: 1 | Parent: / (root)*
