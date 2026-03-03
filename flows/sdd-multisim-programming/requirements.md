# SDD: Multi-SIM Adapter KI Programming

**Дата**: 2026-03-03  
**Статус**: DRAFT  
**Тип**: Spec-Driven Development  
**Модуль**: Multi-SIM KI Programming

---

## 01. Requirements

### Overview

Программирование криптографических ключей (KI, IMSI, ICCID, SMSC) на программируемые мультисим-адаптеры через AT-команды Asterisk chan_dongle.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Поддержка Type 9 (STK) адаптеров | HIGH |
| FR-02 | Поддержка Type 16 (SuperSIM) адаптеров | HIGH |
| FR-03 | Загрузка KI с центрального сервера | HIGH |
| FR-04 | Программирование через dongle | HIGH |
| FR-05 | Валидация запрограммированных данных | HIGH |
| FR-06 | Смена IMEI после программирования | MEDIUM |
| FR-07 | Веб-интерфейс программирования | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Интеграция с Asterisk chan_dongle |
| NFR-02 | Файловое хранение состояния |
| NFR-03 | Логирование операций программирования |
| NFR-04 | Обработка ошибок программирования |

### Constraints

- Требуется активное соединение с dongle
- Адаптер должен быть в режиме программирования
- KI передаётся по HTTP (небезопасно)

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│            Multi-SIM KI Programming                      │
│  ┌─────────────────────────────────────────────────────┐│
│  │  system/new_ki.php - загрузка KI с сервера          ││
│  │  - HTTP GET simserver:8122/new_ki.php               ││
│  │  - Parse KI, IMSI, ICCID, SMSC                      ││
│  └─────────────────────────────────────────────────────┘│
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  system/set_ki.php - программирование адаптера    ││
│  │  - Type 9: STK AT-команды                         ││
│  │  - Type 16: CSIM APDU команды                     ││
│  └───────────────────────────────────────────────────┘  │
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  Asterisk chan_dongle                             ││
│  │  - AT^STGR=... (Type 9)                           ││
│  │  - AT+CSIM=... (Type 16)                          ││
│  └───────────────────────────────────────────────────┘  │
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  Multi-SIM Adapter                                ││
│  │  - Store KI (32 hex)                              ││
│  │  - Store IMSI (18 digits)                         ││
│  │  - Store ICCID (20 digits)                        ││
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Adapter Types

| Type | Name | Programming Interface | Commands |
|------|------|----------------------|----------|
| **Type 9** | 9th Gen | STK (SIM Toolkit) | AT^STGR, AT^STGI |
| **Type 16** | SuperSIM | CSIM APDU | AT+CSIM |

### Data Formats

#### KI (Key Identifier)

- **Length**: 32 hexadecimal characters
- **Example**: `41CDFA30D10DA827404F3A400AD555648D03`
- **Storage**: 128-bit cryptographic key

#### IMSI (International Mobile Subscriber Identity)

- **Length**: 15-18 digits
- **Format**: MCC (3) + MNC (2-3) + MSIN (9-10)
- **Example**: `082905991259443683`
- **Byte-swapped**: `809250991524934638`

#### ICCID (Integrated Circuit Card Identifier)

- **Length**: 19-20 digits
- **Example**: `897019911107987336F`
- **Byte-swapped**: `9807199110783763F6`

#### SMSC (SMS Center)

- **Length**: 24 characters
- **Example**: `0791973007111111F1`

### Type 9 Programming (STK)

**File**: `system/set_ki.php`

```php
<?php
if ($adapter == "9") {
    echo "SET KI 9th generation\n";
    
    // Enter programming mode
    exec_at_command($dongle, 'AT^STGI=0,0');
    exec_at_command($dongle, 'AT^STGR=0,0,1,22');
    exec_at_command($dongle, 'AT^STGI=6,1');
    exec_at_command($dongle, 'AT^STGR=6,1,1,3');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Write KI (hex-encoded)
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_ki) . '"');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Write IMSI (hex-encoded)
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_imsi) . '"');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Write ICCID (hex-encoded)
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_iccid) . '"');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Write SMSC (hex-encoded)
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_smsc) . '"');
    exec_at_command($dongle, 'AT^STGI=6,1');
    exec_at_command($dongle, 'AT^STGI=0,0');
    
    // Select profile 3
    exec_at_command($dongle, 'AT^STGI=0,0');
    exec_at_command($dongle, 'AT^STGR=0,0,1,16');
    exec_at_command($dongle, 'AT^STGI=6,1');
    exec_at_command($dongle, 'AT^STGR=6,1,1,3');
    exec_at_command($dongle, 'AT^STGI=7,1');
    exec_at_command($dongle, 'AT^STGR=7,1,0,""');
    exec_at_command($dongle, 'AT^STGI=0,0');
    
    // Change IMEI and reboot
    system('/usr/sbin/asterisk -rx "dongle changeimei ' . $dongle . ' ' . $imei . '"');
    exec_at_command($dongle, 'AT+CFUN=1,1');
}
?>
```

### Type 16 Programming (SuperSIM)

```php
<?php
if ($adapter == "16") {
    echo "SET KI Supersim 16th generation\n";
    
    // Prepare data with byte-swapping
    $iccid = supersim_make_iccid($dat_iccid);  // 20 chars
    $imsi  = supersim_make_imsi($dat_imsi);    // 18 chars
    $ki    = supersim_make_ki($dat_ki);        // 32 chars
    $smsp  = supersim_make_smsp($dat_smsc);    // 24 chars
    
    // Select DF (Dedicated File)
    exec_at_command($dongle, 'AT+CSIM=14,"A0A4000002A000"');
    
    // Write KI via APDU
    $apdu = build_ki_write_apdu($ki);
    exec_at_command($dongle, 'AT+CSIM=' . strlen($apdu) . ',"' . $apdu . '"');
    
    // Write IMSI via APDU
    $apdu = build_imsi_write_apdu($imsi);
    exec_at_command($dongle, 'AT+CSIM=' . strlen($apdu) . ',"' . $apdu . '"');
    
    // Write ICCID via APDU
    $apdu = build_iccid_write_apdu($iccid);
    exec_at_command($dongle, 'AT+CSIM=' . strlen($apdu) . ',"' . $apdu . '"');
    
    // Verify programming
    verify_ki($dongle, $imsi);
}

function supersim_make_imsi($imsi) {
    // Byte-swap IMSI
    if (strlen($imsi) != 18) { echo("Incorrect IMSI Length!"); die(); }
    
    $a = str_split($imsi);
    return $a[1].$a[0].$a[3].$a[2].$a[5].$a[4].$a[7].$a[6].
           $a[9].$a[8].$a[11].$a[10].$a[13].$a[12].
           $a[15].$a[14].$a[17].$a[16];
}

function supersim_make_iccid($iccid) {
    // Byte-swap ICCID
    if (strlen($iccid) == 19) $iccid .= "F";
    if (strlen($iccid) != 20) { echo("Incorrect ICCID Length!"); die(); }
    
    $a = str_split($iccid);
    return $a[1].$a[0].$a[3].$a[2].$a[5].$a[4].$a[7].$a[6].
           $a[9].$a[8].$a[11].$a[10].$a[13].$a[12].
           $a[15].$a[14].$a[17].$a[16].$a[19].$a[18];
}
?>
```

### KI Fetch from Server

**File**: `system/new_ki.php`

```php
<?php
// Fetch KI from central server
$ki_data = file_get_contents("http://simserver:8122/new_ki.php");

// Parse response
// Format:
// KI:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// IMSI:XXXXXXXXXXXXXXXXX
// ICCID:XXXXXXXXXXXXXXXXXXX
// SMSC:XXXXXXXXXXXXXXXXXXXXXXXX

preg_match('/KI:([A-F0-9]{32})/', $ki_data, $ki_match);
preg_match('/IMSI:(\d{15,18})/', $ki_data, $imsi_match);
preg_match('/ICCID:(\d{19,20})/', $ki_data, $iccid_match);
preg_match('/SMSC:(\d{20,24})/', $ki_data, $smsc_match);

$dat_ki = $ki_match[1];
$dat_imsi = $imsi_match[1];
$dat_iccid = $iccid_match[1];
$dat_smsc = $smsc_match[1];

// Call set_ki.php
$cmd = '/usr/simbox/system/set_ki.php "' . $adapter . '" "' . $dongle . '" "'
     . $dat_ki . '" "' . $dat_imsi . '" "' . $dat_iccid . '" "' . $dat_smsc . '"';
system($cmd);

// Confirm to server
file_get_contents("http://simserver:8122/upload_ki.php?imsi=$dat_imsi&status=ok");
?>
```

### Programming Flow

```
┌─────────────────┐
│  Central Server │
│  simserver:8122 │
│  /new_ki.php    │
└────────┬────────┘
         │ HTTP GET
         │ Response:
         │ KI=...
         │ IMSI=...
         │ ICCID=...
         │ SMSC=...
         ▼
┌─────────────────┐
│  system/new_ki  │
│  - Fetch KI     │
│  - Parse        │
│  - Validate     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  system/set_ki  │
│  - adapter=9/16 │
│  - dongle=X     │
│  - Program      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Asterisk       │
│  chan_dongle    │
│  - AT commands  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Multi-SIM      │
│  Adapter        │
│  - Store KI     │
│  - Store IMSI   │
│  - Store ICCID  │
│  - Store SMSC   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Verify         │
│  - Read back    │
│  - Compare      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Confirm        │
│  to Server      │
└─────────────────┘
```

### AT Command Reference

#### Type 9 (STK) Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `AT^STGI=0,0` | Get menu info | Query main menu |
| `AT^STGR=0,0,1,22` | Select menu | Enter programming |
| `AT^STGR=3,1,1,"hex"` | Write data | KI/IMSI/ICCID/SMSC |
| `AT^STGR=7,1,0,""` | Select profile | Activate profile 3 |
| `AT^STGI=6,1` | Get status | Check operation |

#### Type 16 (CSIM) Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `AT+CSIM=14,"A0A4000002A000"` | Select DF | Enter dedicated file |
| `AT+CSIM=<len>,"<APDU>"` | Write data | KI/IMSI/ICCID |
| `AT+CSIM=<len>,"<APDU>"` | Verify | Authentication challenge |

### Error Handling

```php
<?php
function exec_at_command($dongle, $cmd) {
    $output = shell_exec(
        "asterisk -rx \"dongle cmd $dongle $cmd\" 2>&1"
    );
    
    if (strpos($output, "ERROR") !== false) {
        error_log("AT command failed for $dongle: $cmd");
        return false;
    }
    
    return trim($output);
}

function verify_ki($dongle, $imsi) {
    // Send authentication challenge
    $rand = generate_random_rand();
    $response = exec_at_command($dongle, "AT+CRSM=176,28472,0,0,16,$rand");
    
    // Compare with expected SRES
    $expected = compute_sres($imsi, $ki, $rand);
    
    if ($response === $expected) {
        echo "KI verification SUCCESS\n";
        return true;
    } else {
        echo "KI verification FAILED\n";
        return false;
    }
}
?>
```

### State Files

```
/var/simbox/sim/settings/
├── $imsi.ki              # KI (plaintext, INSECURE)
├── $imsi.iccid           # ICCID
├── $imsi.smsc            # SMSC
└── $imsi.dongle          # Assigned dongle

/var/svistok/sim/state/
├── $imsi.dongle          # Dongle mapping
└── $imsi.str_state       # State string
```

### Security Considerations

**CRITICAL**: KI хранится и передаётся открыто!

1. **HTTP Transmission**: KI передаётся по незащищённому HTTP
2. **Plaintext Storage**: KI хранится в открытых файлах
3. **No Authentication**: Нет проверки подлинности сервера
4. **Log Exposure**: KI может попасть в логи

**Recommendations**:
```php
// Encrypt KI before storage
$encrypted_ki = openssl_encrypt(
    $ki, 
    'AES-256-CBC', 
    $encryption_key,
    0,
    $iv
);
file_put_contents("/var/simbox/sim/settings/$imsi.ki.enc", $encrypted_ki);

// Use HTTPS for server communication
$ki_data = file_get_contents("https://simserver:8122/new_ki.php");

// Clear logs after use
unlink("/tmp/set_ki_$dongle.log");
```

---

## 03. Implementation Plan

### Phase 1: Server Integration

- [ ] Configure simserver:8122 connectivity
- [ ] Test new_ki.php fetch
- [ ] Implement error handling

### Phase 2: Type 9 Programming

- [ ] Test STK commands
- [ ] Verify KI/IMSI/ICCID write
- [ ] Test profile selection

### Phase 3: Type 16 Programming

- [ ] Test CSIM APDU commands
- [ ] Implement byte-swapping
- [ ] Verify programming

### Phase 4: Web Interface

- [ ] Add KI programming page
- [ ] Display progress
- [ ] Show results

---

## 04. Related Documents

- [SDD: SIM Management](../sdd-sim-management/): SIM card lifecycle
- [SDD: SIM Reader](../sdd-sim-reader/): KI extraction
- [ADR-003](../adr-003-multi-sim-adapter/): Multi-SIM Adapter Support
- [ADR-005](../adr-005-central-ki/): Central KI Management
- [Implementation Details](../legacy/understanding/implementation-details.md): KI Programming

---

*Generated by /legacy analysis - 2026-03-03*
