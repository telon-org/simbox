# Understanding: Carrier Parsers

> Operator-specific USSD/SMS parsing and command sets for different mobile carriers

## Phase: EXPLORING

## Hypothesis

Carrier parsers provide operator-specific logic for parsing USSD responses and SMS messages, extracting balance, tariff, and phone number information from different mobile carriers.

## Sources

> Files/directories that inform this understanding

- `nabor/nabor.list` - List of supported operators
- `nabor/tele2_spb/` - Tele2 SPb implementation
- `nabor/beeline_spb/` - Beeline SPb implementation
- `nabor/megafon_spb/` - MegaFon SPb implementation
- `nabor/mts_spb/` - MTS SPb implementation
- `nabor/rostel_spb/` - Rostelekom SPb implementation
- `nabor/kievstar/` - Kievstar (Ukraine) implementation
- `nabor/velcom/` - Velcom (Belarus) implementation
- `nabor/life/` - Life (Belarus) implementation

## Validated Understanding

### Supported Carriers

| Carrier | Region | Directory |
|---------|--------|-----------|
| Tele2 | St. Petersburg | `tele2_spb` |
| Beeline | St. Petersburg | `beeline_spb` |
| MegaFon | Moscow | `megafon_msk` |
| MegaFon | St. Petersburg | `megafon_spb` |
| MTS | St. Petersburg | `mts_spb` |
| Rostelekom | St. Petersburg | `rostel_spb` |
| Kievstar | Ukraine | `kievstar` |
| Velcom | Belarus | `velcom` |
| Life | Belarus | `life` |

### Carrier Module Structure

Each carrier has:
```
nabor/<carrier>/
├── config.sh           # Carrier-specific configuration
├── commands/           # USSD/SMS command scripts
│   ├── activate_sim.sh
│   ├── activate_work.sh
│   ├── get_balance.sh
│   ├── get_number.sh
│   ├── get_tarif.sh
│   └── ...
└── parse/             # Response parsers
    ├── all.php        # Master parser
    ├── parsebalance.php
    ├── parsenumber.php
    ├── parsetarif.php
    └── ...
```

### Carrier Configuration (`config.sh`)

Defines routing groups for SIM state management:
- `GROUP_ZAPAS_PRE/OK` - Reserve SIMs
- `GROUP_WORK_PRE/OK` - Working SIMs
- `GROUP_LOW_BALANCE` - Low balance SIMs
- `GROUP_BLOCKED` - Blocked SIMs

### Parser Examples

**Balance Parsing** (Tele2):
```php
// Cyrillic: "ОСТАТОК 50.00 р."
preg_match("/OCTATOK( munyc)*\s([\d]+.[\d]+)/", $text, $res)
```

**Number Parsing** (Tele2):
```php
preg_match("/Ваш федеральный номер [\- \+]*([0-9\ \-\(\)]*)/", $text, $res)
```

**Tariff Parsing** (Beeline):
```php
preg_match("/Ваш тарифный план[\:]* ([^,]*)/", $text, $res)
```

### USSD Command Examples

| Operation | Carrier | USSD Code |
|-----------|---------|-----------|
| Get Balance | Tele2 | `*105#` |
| Get Number | Tele2 | (custom) |
| Get Tariff | Beeline | (custom) |

### Automation Integration

Commands are invoked from `actions/`:
- `actions/get_balance.sh` calls carrier-specific balance retrieval
- Responses are parsed by carrier-specific parsers
- Data is stored and synced to central server

### Character Encoding Notes

Parsers handle:
- Cyrillic text (Russian)
- Transliterated Latin (carrier SMS fallback)
- Multiple response formats per carrier

## Children Identified

| Child | Hypothesis | Status |
|-------|------------|--------|
| - | Leaf node - no further children | N/A |

## Dependencies

- **Uses**: core-infrastructure (paths), sim-management (upload functions)
- **Used by**: automation, voice-recognition

## Key Insights

1. **Region-specific**: Parsers are region-specific, not just carrier-specific
2. **USSD-based**: Most info retrieved via USSD codes
3. **Cyrillic parsing**: Handles Russian text responses
4. **Group-based routing**: SIM state drives call routing groups

## ADR Candidates

- **ADR: Carrier Plugin Architecture** - Per-carrier module structure
- **ADR: USSD-Based Information Retrieval** - Use of USSD for SIM info

## Flow Recommendation

- **Type**: SDD
- **Confidence**: high
- **Rationale**: Internal parsing logic, no stakeholder documentation needed

## Synthesis

Carrier parsers provide:
1. Per-carrier USSD command sets
2. Response parsing for balance, number, tariff
3. Group assignment for SIM state
4. Multi-region, multi-country support

## Bubble Up

> Summary to pass to parent during EXITING

- 9 carriers across Russia, Ukraine, Belarus
- USSD-based information retrieval
- Regex-based response parsing
- Group-based SIM state management

---

*Phase: EXPLORING | Depth: 1 | Parent: / (root)*
