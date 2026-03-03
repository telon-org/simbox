# SDD: chan_dongle Asterisk Module

**Дата**: 2026-03-03  
**Статус**: APPROVED  
**Тип**: Spec-Driven Development  
**Модуль**: Asterisk chan_dongle Driver

---

## 01. Requirements

### Overview

Модифицированный модуль chan_dongle для Asterisk PBX, обеспечивающий интеграцию с USB GSM-модемами Huawei для маршрутизации голосовых вызовов через GSM-сеть.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Обнаружение USB-модемов (pdiscovery) | HIGH |
| FR-02 | AT-команды через Asterisk CLI | HIGH |
| FR-03 | Голосовые вызовы через GSM | HIGH |
| FR-04 | SMS отправкa/получение | HIGH |
| FR-05 | USSD запросы | HIGH |
| FR-06 | Поддержка мультисим-адаптеров | HIGH |
| FR-07 | Интеграция с SimNode | MEDIUM |
| FR-08 | Диагностика модемов | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Совместимость с Asterisk 11/18 |
| NFR-02 | Поддержка Huawei E1550, E173, E303 |
| NFR-03 | Low-latency audio processing |
| NFR-04 | Thread-safe операции |

### Constraints

- Требуется патчинг Asterisk (chan_sip.c, dsp.c)
- Модификации chan_dongle для SimNode
- Специфичные драйверы для Huawei

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Asterisk PBX                            │
│  ┌─────────────────────────────────────────────────────┐│
│  │              chan_dongle Module                      ││
│  │  ┌──────────────┬──────────────┬─────────────────┐  ││
│  │  │ pdiscovery.c │ adiscovery.c │ at_command.c    │  ││
│  │  │ Device disc  │ SIM discovery│ AT cmd queue    │  ││
│  │  ├──────────────┼──────────────┼─────────────────┤  ││
│  │  │ at_response  │ channel.c    │ manager.c       │  ││
│  │  │ Parser       │ Call logic   │ AMI integration │  ││
│  │  └──────────────┴──────────────┴─────────────────┘  ││
│  └─────────────────────────────────────────────────────┘│
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  Patched Components                               │  │
│  │  - chan_sip.c (SIP integration)                   │  │
│  │  - dsp.c (DSP processing)                         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Device Discovery (pdiscovery.c)

**Path**: `svistok-aa/pdiscovery.c`

```c
// Device IDs for Huawei modems
static const struct pdiscovery_device device_ids[] = {
    { 0x12d1, 0x1001, { 2, 1, 0 } },    // E1550 generic
    { 0x12d1, 0x140c, { 3, 2, 0 } },    // E17xx
    { 0x12d1, 0x1436, { 3, 2, 1 } },    // E173
    { 0x12d1, 0x14ac, { 3, 2, 1 } },    // E1550
    { 0x12d1, 0x1506, { 2, 1, 3 } },    // E303/E353
};

// Port discovery
#define PDISCOVERY_TIMEOUT 1000  // milliseconds

struct pdiscovery_result {
    char *imei;
    char *imsi;
    char *serial;
    struct pdiscovery_ports {
        char *ports[INTERFACE_TYPE_NUMBERS];
    } ports;
};
```

### adiscovery (SIM Discovery)

**Path**: `svistok-aa/simnode/adiscovery_*.c`

```c
// adiscovery_svistok.c
static int pvt_adiscovery(struct pvt *pvt) {
    if (CONF_UNIQ(pvt, data_tty)[0] != 0) {
        ast_copy_string(PVT_STATE(pvt, data_tty), 
                       CONF_UNIQ(pvt, data_tty), 
                       sizeof(PVT_STATE(pvt, data_tty)));
        return usbdev_get_audioport(CONF_UNIQ(pvt, data_tty), 
                                    PVT_STATE(pvt, audio_tty));
    }
    return 0;
}

// adiscovery_core.c - USB device definitions
defdev_t defdevs[] = {
    // {model, mode, idVendor, idProduct, interfaces, dataport, audioport, netport}
    {200, 1, 0x12d1, 0x1001, {...}, 2, 1, -1},   // E1550
    {9173, 1, 0x12d1, 0x1436, {...}, 4, 3, 1},   // E173
    {9550, 1, 0x12d1, 0x14ac, {...}, 3, 2, -1},  // E1550
    {3276, 1, 0x12d1, 0x1506, {...}, 1, 0, 2},   // E303
    {1616, 1, 0x67b, 0x2303, {...}, 0, -1, -1},  // PL2303 (reader)
};
```

### AT Command Processing

**Path**: `svistok-aa/at_command.c`

```c
// AT command queue structure
struct at_queue_task {
    struct at_queue_task_cmd {
        const char *cmd;
        int (*response_handler)(struct pvt *, const char *);
        int timeout;
    } cmds[AT_QUEUE_MAX_CMDS];
};

// Key AT commands for Huawei
#define AT_CMD_CFUN "AT+CFUN"        // Power control
#define AT_CMD_CGSN "AT+CGSN"        // Get IMEI
#define AT_CMD_CIMI "AT+CIMI"        // Get IMSI
#define AT_CMD_CCID "AT+CCID"        // Get ICCID
#define AT_CMD_CUSD "AT+CUSD"        // USSD
#define AT_CMD_CMGS "AT+CMGS"        // Send SMS
#define AT_CMD_STGR "AT^STGR"        // STK (Type 9 adapter)
#define AT_CMD_CSIM "AT+CSIM"        // CSIM (Type 16 adapter)
```

### Channel Driver (chan_dongle.c)

**Path**: `svistok-aa/chan_dongle.c`

```c
// Module metadata
char svistok_version[64] = "1.1200";

// Device state strings
EXPORT_DEF const char * const dev_state_strs[4] = { 
    "stop", "restart", "remove", "start" 
};

// Lock management
static int lock_try(const char *devname, char **lockname) {
    // Try to acquire device lock
    // Returns PID of owner or 0 if free
}

static int lock_create(const char *lockfile) {
    // Create lock file with PID
}

// Port status check
static int port_status(int fd) {
    struct termios t;
    return tcgetattr(fd, &t);
}
```

### Patched Components

#### chan_sip.c

**Path**: `asterisk.patch/chan_sip.c`

**Modifications**:
- Интеграция с chan_dongle для SIP-GSM маршрутизации
- Обработка вызовов через GSM modem
- Caller ID injection

#### dsp.c

**Path**: `asterisk.patch/dsp.c`

**Modifications**:
- DSP processing для GSM audio
- DTMF detection оптимизация
- Progress tone detection (US/UK/CR modes)

### Interface Definitions

#### Asterisk CLI Commands

```
dongle show stats          # Show dongle statistics
dongle show devices        # List connected devices
dongle cmd <dev> <AT>      # Execute AT command
dongle sms <dev> <num> <text>  # Send SMS
dongle ussd <dev> <code>   # Send USSD
dongle restart <dev>       # Restart dongle
dongle changeimei <dev> <imei>  # Change IMEI
dongle setgroupimsi <imsi> <group>  # Set routing group
```

#### Manager Events (AMI)

```
Event: DongleStatus
Dongle: dongle01
Status: Connected
IMEI: 353456071234567
IMSI: 250201234567890
Operator: MegaFon

Event: DongleSMS
Dongle: dongle01
From: +79991234567
Text: Hello

Event: DongleUSSD
Dongle: dongle01
Text: Balance: 100.50 RUB
```

### Audio Path Configuration

```c
// Interface endpoint mapping for Huawei E1550
{
    .model = 200,
    .mode = 1,  // Work mode
    .idVendor = 0x12d1,
    .idProduct = 0x1001,
    .iface = {
        {1, {0x01, 0x00, 0x81}},  // Interface 0: Data
        {1, {0x02, 0x82, 0x83}},  // Interface 1: Audio
        {0}
    },
    .dataport_num = 2,
    .audioport_num = 1,
    .netport_num = -1
}
```

### Error Handling

```c
// Device disconnect detection
static int dongle_check_device(struct pvt *pvt) {
    if (port_status(pvt->data_fd) < 0) {
        // Device disconnected
        manager_event_message_raw("DongleDisconnected", ...);
        return -1;
    }
    return 0;
}

// AT command timeout
static int at_command_timeout(struct pvt *pvt, int timeout_ms) {
    struct timeval start = ast_tvnow();
    while (ast_tvdiff_ms(ast_tvnow(), start) < timeout_ms) {
        if (at_wait(pvt->data_fd, 100) > 0) {
            return at_read_result(pvt);
        }
    }
    return -ETIMEDOUT;
}
```

### Security Considerations

- **Device locks**: /var/lock/LOCK..ttyUSB* prevents conflicts
- **Sudo permissions**: Required for USB device access
- **AMI authentication**: Required for manager events
- **IMEI changing**: May violate local regulations

---

## 03. Implementation Plan

### Phase 1: Build chan_dongle

- [ ] Configure Asterisk source tree
- [ ] Apply patches (chan_sip.c, dsp.c)
- [ ] Compile chan_dongle module
- [ ] Install to Asterisk modules/

### Phase 2: Device Discovery

- [ ] Test pdiscovery for modem detection
- [ ] Configure adiscovery for SIM detection
- [ ] Verify port mapping (data/audio)

### Phase 3: Integration

- [ ] Configure dongle.conf
- [ ] Test AT command execution
- [ ] Verify voice calls through GSM

### Phase 4: Testing

- [ ] Test SMS send/receive
- [ ] Test USSD queries
- [ ] Test multi-SIM adapter support
- [ ] Load testing with multiple modems

---

## 04. Related Documents

- [SDD: Dongle Control](../sdd-dongle-control/): USB modem management
- [SDD: Multi-SIM Programming](../sdd-multisim-programming/): KI programming
- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [Implementation Details](../legacy/understanding/implementation-details.md): chan_dongle

---

*Generated by /legacy analysis - 2026-03-03*
