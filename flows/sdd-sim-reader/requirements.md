# SDD: SIM Card Reader & KI Extraction

**Дата**: 2026-03-03  
**Статус**: DRAFT  
**Тип**: Spec-Driven Development  
**Модуль**: SIM Reader & KI Extraction

---

## 01. Requirements

### Overview

Система чтения KI (Key Identifier) с физических SIM-карт с использованием USB-ридеров и алгоритмов Comp128v1 для клонирования и программирования мультисим-адаптеров.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Поддержка Dejian CardReader | HIGH |
| FR-02 | Чтение IMSI/ICCID | HIGH |
| FR-03 | Извлечение KI (Comp128v1) | HIGH |
| FR-04 | Атаки на KI (2R/3R/4R/5R) | MEDIUM |
| FR-05 | Brute-force KI | MEDIUM |
| FR-06 | Веб-интерфейс управления | MEDIUM |
| FR-07 | Интеграция с центральным сервером | HIGH |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Low-priority execution (nice, ionice) |
| NFR-02 | Файловое хранение результатов |
| NFR-03 | Логирование операций |
| NFR-04 | Поддержка нескольких ридеров |

### Constraints

- Физический доступ к SIM-карте required
- Некоторые SIM заблокированы от чтения KI
- Время чтения: 30 минут - 24 часа

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│               SIM Reader & KI Extraction                 │
│  ┌─────────────────────────────────────────────────────┐│
│  │  wtss/wts.pas (Pascal) - основное приложение        ││
│  │  - Управление портом (SynaSer)                      ││
│  │  - GSM алгоритмы (Comp128v1)                        ││
│  │  - Атаки на KI (2R, 3R, 4R, 5R, BF)                ││
│  └─────────────────────────────────────────────────────┘│
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  svistok-aa/reader/ (C) - low-level драйвер       │  │
│  │  - reader_core.c/h - базовые операции             │  │
│  │  - emulator.c - эмулятор SIM                      │  │
│  │  - adapter.c - работа с адаптером                 │  │
│  └───────────────────────────────────────────────────┘  │
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  www/simbox/readers.php - веб-интерфейс           ││
│  │  - Запуск чтения KI                               ││
│  │  - Мониторинг прогресса                           ││
│  │  - Просмотр результатов                           ││
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Supported Devices

| Device | Type | Interface | Status |
|--------|------|-----------|--------|
| **Dejian CardReader** | PC/SC | USB (ttyUSB) | ✓ Active |
| **USI 2.0** | ISO 7816 | Serial | ✓ Active |
| **Ericsson R520m** | Phone cable | Serial | ⚠ Legacy |
| **Ericsson R520s** | Service cable | Serial | ⚠ Legacy |
| **Ericsson R520d** | LPT dongle | Parallel | ✗ Deprecated |
| **Comp128v1 Emulator** | Software | Internal | ✓ Test |

### Reader Data Structure

**File**: `svistok-aa/reader/reader_core.h`

```c
#define MAXREADERDEVICES 512
#define DEVPATHLEN 256

#define SIMTIMEOUT 1000
#define READER_DATA_READ_TIMEOUT 500

typedef struct rdr {
    char dev[DEVPATHLEN];           // Device path (/dev/ttyUSB*)
    char data_tty[DEVPATHLEN];      // Data port
    int data_fd;                    // File descriptor
    char *data_lock;                // Lock pointer
    
    int timeout;                    // Timeout in ms
    unsigned int connected;         // Connection flag
    
    char iccid[64];                 // ICCID (19-20 digits)
    char imsi[64];                  // IMSI (15-18 digits)
    char ki[64];                    // KI (32 hex chars)
    char spn[64];                   // Service Provider Name
    
    int haspin;                     // PIN required flag
} rdr_t;
```

### wts.pas - Main Application

**Path**: `wtss/wts.pas`

```pascal
program WTS;
{ Wert SIM-Card Scanner }
{ Version 1.0.6 }

uses SynaSer, SysUtils, Tables, WTypes, Functions;

const
    VERSION = '1.0.6';
    PORTNAME = '/dev/ttyS0';
    PORTSPEED = 9600;

var
    Port: TBlockSerial;
    ResKi: TData16;
    IMSI: String[18];
    ICCID: String[22];
    ResultKI: Longint;

procedure WriteHelp;
begin
    LWriteln('--device=reader     : Using CardReader (Dejian, USI 2.0)', 2);
    LWriteln('--port=<name>        : Device port name [default /dev/ttyS0]', 2);
    LWriteln('--speed=<number>     : Port speed [9600, 19200, 38400]', 2);
    LWriteln('--ignorects          : Dont use CTS for device checking', 2);
    LWriteln('--imsi               : Read IMSI', 2);
    LWriteln('--gsm                : Run GSM-algo (find KI)', 2);
    LWriteln('--findkiv1=<num>     : Find KI v1, start from pair <num>', 2);
end;

begin
    // Parse command line
    // Initialize port
    // Read SIM
    // Extract KI
    // Save results
end.
```

### KI Attack Methods

| Attack | Pairs Required | Time | Success Rate |
|--------|----------------|------|--------------|
| **2R (v1)** | 2 | ~5 min | ~30% |
| **3R (v1)** | 3 | ~30 min | ~70% |
| **4R (v1)** | 4 | ~2 hours | ~90% |
| **5R (v1)** | 5 | ~6 hours | ~95% |
| **Brute Force** | 7 | ~24 hours | ~99% |

### Web Interface (readers.php)

**Path**: `www/simbox/readers.php`

```php
<?php
// Start KI extraction
if (isset($_POST['findki'])) {
    foreach ($_POST['id'] as $v => $device) {
        $dataport = file_get_contents_def2(
            "/var/svistok/devices/$device.dataport", ""
        );
        
        // Run wts in background with low priority
        $cmd = 'sudo nice -n 19 ionice -c3 '
             . '/usr/simbox/wtss/wts '
             . '--svistokmode=1 '
             . '--device=reader '
             . '--speed=9600 '
             . '--ignorects '
             . '--port=' . $dataport . ' '
             . '--dev=' . $device . ' '
             . '> /tmp/reader_' . $device . '.log &';
        
        echo($cmd . "<br>");
        exec_delay($cmd);
        sleep(1);
        flush();
    }
}

// Display readers table
$data = @file("/var/svistok/lists/readers.list");
foreach ($data as $i => $v) {
    $device = trim($v);
    $iccid = file_get_contents_def2("/var/svistok/readers/state/$device.iccid", "");
    $state = file_get_contents_def2("/var/svistok/readers/state/$device.status", "Not connected");
    $result = file_get_contents_def2("/var/svistok/readers/sim/$iccid.result", "0");
    $imsi = file_get_contents_def2("/var/svistok/readers/sim/$iccid.imsi", "");
    $ki = file_get_contents_def2("/var/svistok/readers/sim/$iccid.ki", "");
    $progress = floor(@filesize("/var/svistok/readers/sim/$iccid.gsm") / 58);
    ?>
    <tr>
        <td><input type="checkbox" name="id[]" value="<?=$device?>"></td>
        <td><?=$device?></td>
        <td><?=$state?></td>
        <td><?=$iccid?></td>
        <td><?=$imsi?></td>
        <td><?=$ki?></td>
        <td><?=$progress?> pairs</td>
        <td><?=$result?></td>
    </tr>
    <?php
}
?>
```

### State Files

```
/var/svistok/
├── lists/
│   └── readers.list          # List of reader devices
├── devices/
│   └── $device.dataport      # Data port path
└── readers/
    ├── state/
    │   ├── $device.status    # Current status
    │   ├── $device.iccid     # ICCID
    │   ├── $device.lock      # Lock file
    │   ├── $device.spn       # Operator
    │   └── $device.pin       # PIN status
    └── sim/
        ├── $ICCID.imsi       # IMSI
        ├── $ICCID.ki         # KI (32 hex)
        ├── $ICCID.gsm        # RAND-SRES pairs (58 bytes each)
        ├── $ICCID.result     # Result code (1000+error)
        └── $ICCID.log        # Full operation log
```

### Result Codes

| Code | Meaning |
|------|---------|
| 1000 | Success, KI found |
| 1001 | Read error |
| 1002 | Wrong PIN |
| 1003 | SIM blocked |
| 1004 | Card removed |
| 1005 | Timeout |

### KI Extraction Flow

```
┌─────────────────┐
│  Insert SIM     │
│  into Reader    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Read ICCID     │
│  /var/svistok/  │
│  readers/state/ │
│  $device.iccid  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Read IMSI      │
│  /var/svistok/  │
│  readers/sim/   │
│  $ICCID.imsi    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  GSM Algorithm  │
│  (Comp128v1)    │
│  Send RAND →    │
│  Receive SRES   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Store Pair     │
│  $ICCID.gsm     │
│  (58 bytes)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Attack (2R-5R) │
│  Calculate KI   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Save KI        │
│  $ICCID.ki      │
│  Result: 1000   │
└─────────────────┘
```

### Security Considerations

**CRITICAL**: KI хранится в открытом виде!

```bash
# Plaintext KI file (INSECURE)
/var/svistok/readers/sim/$ICCID.ki
# Content: 41CDFA30D10DA827404F3A400AD555648D03

# Log file with KI (INSECURE)
/tmp/reader_dongle01.log
# Contains: KI=41CDFA30D10DA827404F3A400AD555648D03
```

**Recommendations**:
1. Encrypt KI files
2. Clear /tmp logs after use
3. Restrict file permissions (chmod 600)
4. Audit access to reader directories

---

## 03. Implementation Plan

### Phase 1: Build wts

- [ ] Compile wtss/wts.pas with Free Pascal
- [ ] Install to /usr/simbox/wtss/
- [ ] Test with Dejian reader

### Phase 2: Configure Readers

- [ ] Connect USB readers
- [ ] Populate /var/svistok/lists/readers.list
- [ ] Configure device ports

### Phase 3: Web Interface

- [ ] Display reader status table
- [ ] Add "Find KI" button
- [ ] Implement progress monitoring

### Phase 4: Testing

- [ ] Test IMSI/ICCID reading
- [ ] Test KI extraction (2R attack)
- [ ] Verify result files

---

## 04. Related Documents

- [SDD: SIM Management](../sdd-sim-management/): SIM card lifecycle
- [SDD: USB Hub Power](../sdd-usb-hub-power/): USB hub control
- [ADR-003](../adr-003-multi-sim-adapter/): Multi-SIM Adapter Support
- [Implementation Details](../legacy/understanding/implementation-details.md): SIM Reader & KI

---

*Generated by /legacy analysis - 2026-03-03*
