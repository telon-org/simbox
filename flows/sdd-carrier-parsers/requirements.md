# SDD: Carrier Parsers

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Spec-Driven Development  
**Module**: Carrier Parsers

---

## 01. Requirements

### Overview

Carrier Parsers provide operator-specific USSD/SMS parsing and command sets for different mobile carriers across Russia, Ukraine, and Belarus.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Parse balance from USSD response | HIGH |
| FR-02 | Parse phone number from USSD response | HIGH |
| FR-03 | Parse tariff from USSD response | HIGH |
| FR-04 | Send carrier-specific USSD commands | HIGH |
| FR-05 | Support 9 carriers across 3 countries | HIGH |
| FR-06 | Handle Cyrillic and Latin text | HIGH |
| FR-07 | Assign SIM to routing group based on state | MEDIUM |
| FR-08 | Parse SMS fallback responses | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Per-carrier module structure (plugin architecture) |
| NFR-02 | Regex-based response parsing |
| NFR-03 | Support for multiple response formats |
| NFR-04 | Russian language UI and comments |

### Constraints

- Carrier USSD codes may change without notice
- Response format varies by region
- Some carriers use Latin transliteration in SMS

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Carrier Parsers Module                  │
│  ┌─────────────────────────────────────────────────────┐│
│  │                   nabor/                            ││
│  │  ┌──────────┬──────────┬──────────┬──────────────┐ ││
│  │  │ tele2_   │ beeline_ │ megafon_ │ mts_         │ ││
│  │  │ spb/     │ spb/     │ spb/     │ spb/         │ ││
│  │  ├──────────┼──────────┼──────────┼──────────────┤ ││
│  │  │ config.sh│ config.sh│ config.sh│ config.sh    │ ││
│  │  │ commands/│ commands/│ commands/│ commands/    │ ││
│  │  │ parse/   │ parse/   │ parse/   │ parse/       │ ││
│  │  └──────────┴──────────┴──────────┴──────────────┘ ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

### Supported Carriers

| Carrier | Region | Directory | USSD Balance |
|---------|--------|-----------|--------------|
| Tele2 | St. Petersburg | tele2_spb | *105# |
| Beeline | St. Petersburg | beeline_spb | *102# |
| MegaFon | Moscow | megafon_msk | *100# |
| MegaFon | St. Petersburg | megafon_spb | *100# |
| MTS | St. Petersburg | mts_spb | *100# |
| Rostelekom | St. Petersburg | rostel_spb | *100# |
| Kievstar | Ukraine | kievstar | *111# |
| Velcom | Belarus | velcom | *100# |
| Life | Belarus | life | *100# |

### Carrier Module Structure

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
└── parse/              # Response parsers
    ├── all.php         # Master parser
    ├── parsebalance.php
    ├── parsenumber.php
    ├── parsetarif.php
    └── ...
```

### Configuration (config.sh)

```bash
#!/bin/bash
# Tele2 St. Petersburg configuration

# Routing groups
GROUP_ZAPAS_PRE="tele2_zapas"
GROUP_ZAPAS_OK="tele2_zapas_ok"
GROUP_WORK_PRE="tele2_work"
GROUP_WORK_OK="tele2_work_ok"
GROUP_LOW_BALANCE="tele2_low"
GROUP_BLOCKED="tele2_blocked"

# USSD codes
USSD_BALANCE="*105#"
USSD_NUMBER="*105#0"
USSD_TARIFF="*105#3"

# Parser paths
PARSE_BALANCE="/usr/simbox/nabor/tele2_spb/parse/parsebalance.php"
PARSE_NUMBER="/usr/simbox/nabor/tele2_spb/parse/parsenumber.php"
PARSE_TARIFF="/usr/simbox/nabor/tele2_spb/parse/parsetarif.php"
```

### Parser Examples

#### Balance Parsing (Tele2)

```php
// nabor/tele2_spb/parse/parsebalance.php
<?php
$text = $argv[1];  // USSD response text

// Cyrillic: "ОСТАТОК 50.00 р."
// Latin fallback: "OSTATOK 50.00 r."
preg_match("/OCTATOK( munyc)*\s([\d]+.[\d]+)/", $text, $res);

if (isset($res[2])) {
    echo $res[2];  // Output: 50.00
} else {
    echo "ERROR";
}
?>
```

#### Number Parsing (Tele2)

```php
// nabor/tele2_spb/parse/parsenumber.php
<?php
$text = $argv[1];

// "Ваш федеральный номер +7 (999) 123-45-67"
preg_match(
    "/Ваш федеральный номер [\- \+]*([0-9\ \-\(\)]*)/",
    $text, $res
);

if (isset($res[1])) {
    // Normalize: remove spaces, dashes, parens
    $number = preg_replace('/[\s\-\(\)]/', '', $res[1]);
    echo $number;
} else {
    echo "ERROR";
}
?>
```

#### Tariff Parsing (Beeline)

```php
// nabor/beeline_spb/parse/parsetarif.php
<?php
$text = $argv[1];

// "Ваш тарифный план: Безлимит"
preg_match("/Ваш тарифный план[\:]* ([^,]*)/", $text, $res);

if (isset($res[1])) {
    echo trim($res[1]);
} else {
    echo "ERROR";
}
?>
```

### USSD Command Flow

```bash
# actions/get_balance.sh
#!/bin/bash
IMS I=$1
DONGLE=$2
CARRIER=$3

# Send USSD via Asterisk
RESPONSE=$(asterisk -rx "dongle cmd $DONGLE AT+CUSD=1,\"*105#\",15")

# Parse response
BALANCE=$(/usr/simbox/nabor/$CARRIER/parse/parsebalance.php "$RESPONSE")

# Save and upload
/usr/simbox/modules/save_balance.php $IMSI $BALANCE
/usr/simbox/modules/upload_balance.php $IMSI $BALANCE
```

### Character Encoding

Parsers handle both Cyrillic and Latin:

```php
// Handle Cyrillic text
$text = mb_convert_encoding($text, 'UTF-8', 'Windows-1251');

// Some carriers send Latin transliteration
// "ОСТАТОК" -> "OSTATOK"
// "БАЛАНС" -> "BALANS"

// Parser should handle both
preg_match("/(ОCTATOK|OSTATOK)\s([\d.]+)/", $text, $res);
```

### Interface Definitions

#### Parser API

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `parse_balance` | `$text`, `$carrier` | `float` | Extract balance |
| `parse_number` | `$text`, `$carrier` | `string` | Extract phone number |
| `parse_tariff` | `$text`, `$carrier` | `string` | Extract tariff name |
| `get_ussd_cmd` | `$operation`, `$carrier` | `string` | Get USSD code |

### Error Handling

```php
// Master parser (all.php)
<?php
$carrier = $argv[1];
$text = $argv[2];
$type = $argv[3];  // balance, number, tarif

$parser = "/usr/simbox/nabor/{$carrier}/parse/parse{$type}.php";

if (!file_exists($parser)) {
    error_log("Parser not found: $parser");
    echo "ERROR";
    exit(1);
}

$result = shell_exec("php $parser " . escapeshellarg($text));

if (trim($result) === "ERROR") {
    error_log("Parse failed for $carrier $type");
}

echo $result;
?>
```

### Security Considerations

- No input validation on USSD responses
- Shell execution of parser scripts
- Carrier USSD codes may incur charges

---

## 03. Implementation Plan

### Phase 1: Parser Review

- [ ] Audit all 9 carrier parsers
- [ ] Test regex patterns with sample responses
- [ ] Document response formats per carrier

### Phase 2: Command Sets

- [ ] Verify USSD codes for all carriers
- [ ] Test command execution flow
- [ ] Add error handling for failed USSD

### Phase 3: Testing

- [ ] Test with real USSD responses
- [ ] Test edge cases (zero balance, special characters)
- [ ] Test carrier switching

---

## 04. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [ADR-002](../adr-002-imsi-centric-model/): IMSI-Centric Data Model
- [ADR-004](../adr-004-zone-routing/): Zone-Based Call Routing
- [SDD: SIM Management](../sdd-sim-management/): SIM card lifecycle

---

*Generated by /legacy analysis - 2026-03-03*
