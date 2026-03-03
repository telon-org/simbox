# SDD: USB Hub Power Management

**Дата**: 2026-03-03  
**Статус**: DRAFT  
**Тип**: Spec-Driven Development  
**Модуль**: USB Hub Power Control

---

## 01. Requirements

### Overview

Система управления питанием USB-портов для аппаратной перезагрузки GSM-модемов через программное управление USB-хабами.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Обнаружение USB-хабов в системе | HIGH |
| FR-02 | Управление питанием отдельных портов | HIGH |
| FR-03 | Массовая перезагрузка всех портов | HIGH |
| FR-04 | Поддержка Terminus/DUB-H7 хабов | HIGH |
| FR-05 | Веб-интерфейс управления хабами | MEDIUM |
| FR-06 | Отложенное выполнение команд | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Низкоуровневый доступ через libusb |
| NFR-02 | Выполнение от root (sudo) |
| NFR-03 | Задержка 2 секунды между выкл/вкл |
| NFR-04 | Логирование операций |

### Constraints

- Требуется физический доступ к USB-хабам
- Поддержка только определённых моделей хабов
- Команды выполняются с привилегиями root

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 Hub Power Management                     │
│  ┌─────────────────────────────────────────────────────┐│
│  │  hub-ctrl.c (C/libusb) - утилита управления         ││
│  │  - Поиск хабов по vendor ID                         ││
│  │  - Управление питанием портов                       ││
│  └─────────────────────────────────────────────────────┘│
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  system/repowerall.sh - скрипт массовой перезагрузки││
│  │  - lsusb для обнаружения                          ││
│  │  - Цикл по всем хабам и портам                    ││
│  └───────────────────────────────────────────────────┘  │
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  www/simbox/hubs.php - веб-интерфейс              ││
│  │  - Отображение хабов                              ││
│  │  - Кнопки вкл/выкл/перезагрузка                   ││
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Supported Hardware

| Hub Model | Vendor ID | Product ID | Support |
|-----------|-----------|------------|---------|
| Terminus Hub | 0x0424 | 0x2514 | ✓ Full |
| D-Link DUB-H7 | 0x2001 | 0x3A02 | ✓ Full |
| Generic 7-port | 0x1a40 | 0x0101 | ✓ Full |

### hub-ctrl Utility

**Source**: `svistok-aa/hub-ctrl.c`

**Compilation**:
```bash
gcc hub-ctrl.c -lusb -o /usr/simbox/bin/hub-ctrl
```

**Syntax**:
```bash
hub-ctrl -b <bus> -d <device> -P <port> -p <power>
```

| Parameter | Description | Range | Example |
|-----------|-------------|-------|---------|
| `-b` | USB bus number | 001-999 | 001 |
| `-d` | Device number | 001-999 | 001 |
| `-P` | Port number on hub | 1-7 | 01 |
| `-p` | Power state | 0=OFF, 1=ON | 0 |

**Exit Codes**:
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Hub not found |
| 2 | Port not found |
| 3 | Permission denied |

### repowerall.sh Script

**Path**: `system/repowerall.sh`

```bash
#!/bin/sh

hubctrl="/usr/simbox/bin/hub-ctrl"

# Find all hubs
hubs=`lsusb | grep DUB-H7 | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`
hubs2=`lsusb | grep 1a40:0101 | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`
hubs3=`lsusb | grep Terminus | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`

hubs="$hubs $hubs2 $hubs3"

for hub in $hubs
do
    echo "HUB=$hub"
    
    # Get ports
    ports=`lsusb -v -s $hub | grep -o -R "Port [0-9]: " | grep -o -R "[0-9]:" | sed 's/://g'`
    
    for port in $ports
    do
        # Extract bus and device
        b=`echo "$hub" | grep -o -R "[0-9]*:" | sed 's/://g'`
        d=`echo "$hub" | grep -o -R ":[0-9]*" | sed 's/://g'`
        
        # Power OFF
        echo "OFF"
        $hubctrl -b $b -d $d -P $port -p 0
        sleep 2
        
        # Power ON
        echo "ON"
        $hubctrl -b $b -d $d -P $port -p 1
        sleep 2
    done
done

echo "DONE"
```

### Web Interface (hubs.php)

**Path**: `www/simbox/hubs.php`

```php
<?php
// Power control
if ((isset($_POST['poff'])) || (isset($_POST['pon'])) || (isset($_POST['prestart']))) {
    $onoff = 0;
    if (isset($_POST['pon'])) $onoff = 1;
    if (isset($_POST['prestart'])) $onoff = 2;
    
    foreach ($_POST['id'] as $v => $adr) {
        @list($bus, $dev, $port) = explode(":", $adr);
        
        if (($dev > 0) && ($port > 0)) {
            if ($onoff == 0) {
                // Power OFF
                $cmd = "/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 0";
            }
            if ($onoff == 1) {
                // Power ON
                $cmd = "/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 1";
            }
            if ($onoff == 2) {
                // Reboot (OFF/ON)
                $cmd = "/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 0 && "
                      ."/bin/sleep 2 && "
                      ."/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 1";
            }
            
            echo($cmd . "<br>");
            exec_delay($cmd);
        }
    }
}
?>
```

### Hub Display Table

```php
<table>
<tr class="header">
    <td><input type="checkbox" name="idall" onClick="SelAll(this)"></td>
    <td>Hub</td>
    <td>Port</td>
    <td>Device</td>
    <td>Status</td>
</tr>

<?php
$hubs = file("/var/svistok/lists/hubs.list");
foreach ($hubs as $hub_line) {
    @list($bus, $dev, $ports) = explode(":", trim($hub_line));
    
    for ($port = 1; $port <= 7; $port++) {
        $status = get_port_status($bus, $dev, $port);
        ?>
        <tr>
            <td><input type="checkbox" name="id[]" value="<?=$bus?>:<?=$dev?>:<?=$port?>"></td>
            <td>Hub <?=$bus?>:<?=$dev?></td>
            <td>Port <?=$port?></td>
            <td><?=get_device_name($bus, $dev, $port)?></td>
            <td><?=$status?></td>
        </tr>
        <?php
    }
}
?>
</table>
```

### State Files

```
/var/svistok/lists/
├── hubs.list           # Список хабов (bus:device:ports)
└── readers.list        # Список ридеров

/var/svistok/devices/
└── $device.dataport    # Data-порт устройства
```

### Error Handling

```bash
#!/bin/sh
# Проверка доступности хаба

check_hub() {
    bus=$1
    dev=$2
    
    if ! lsusb -s $bus:$dev > /dev/null 2>&1; then
        echo "ERROR: Hub $bus:$dev not found"
        return 1
    fi
    return 0
}

check_port() {
    bus=$1
    dev=$2
    port=$3
    
    # Проверка существования порта
    if ! lsusb -v -s $bus:$dev | grep -q "Port $port:"; then
        echo "ERROR: Port $port not found on hub $bus:$dev"
        return 1
    fi
    return 0
}
```

### Security Considerations

- **Sudo required**: Команды выполняются от root
- **Physical access**: Требуется физический доступ к USB
- **Device disruption**: Отключение питания может повредить данные

**Recommended sudoers**:
```bash
# /etc/sudoers
asterisk ALL=(ALL) NOPASSWD: /usr/simbox/bin/hub-ctrl
www-data ALL=(ALL) NOPASSWD: /usr/simbox/bin/hub-ctrl
```

---

## 03. Implementation Plan

### Phase 1: Build hub-ctrl

- [ ] Compile hub-ctrl.c with libusb
- [ ] Install to /usr/simbox/bin/
- [ ] Configure sudo permissions

### Phase 2: Test Hub Detection

- [ ] Run lsusb to identify hubs
- [ ] Populate /var/svistok/lists/hubs.list
- [ ] Verify port detection

### Phase 3: Web Interface

- [ ] Display hub/port table
- [ ] Add power control buttons
- [ ] Implement delayed execution

### Phase 4: Testing

- [ ] Test single port power cycle
- [ ] Test mass reboot all ports
- [ ] Verify modem recovery after reboot

---

## 04. Related Documents

- [SDD: Dongle Control](../sdd-dongle-control/): USB modem management
- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [Implementation Details](../legacy/understanding/implementation-details.md): USB Hub Management

---

*Generated by /legacy analysis - 2026-03-03*
