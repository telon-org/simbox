# SimBox: Технические детали реализации

**Дата**: 2026-03-03  
**Автор**: Антон Додонов, NativeMind.net  
**Тип**: Техническая документация

---

## 1. Управление USB-хабами

### Обзор

Система использует **программное управление питанием USB-портов** для перезагрузки GSM-модемов на аппаратном уровне. Это необходимо когда программная перезагрузка через AT-команды не работает.

### Аппаратная часть

**Поддерживаемые USB-хабы:**
- **Terminus Hub** (наиболее распространённый)
- **DUB-H7** (D-Link)
- **1a40:0101** (Generic 7-port hub)

### Утилита hub-ctrl

Собственная утилита для управления питанием USB-портов:

**Путь**: `svistok-aa/hub-ctrl.c` → `/usr/simbox/bin/hub-ctrl`

```c
// Компиляция
gcc hub-ctrl.c -lusb -o /usr/simbox/bin/hub-ctrl
```

**Синтаксис:**
```bash
hub-ctrl -b <bus> -d <device> -P <port> -p <power>
```

| Параметр | Описание | Пример |
|----------|----------|--------|
| `-b` | Номер USB-шины (bus) | 001 |
| `-d` | Номер устройства (device) | 001 |
| `-P` | Номер порта на хабе | 01-07 |
| `-p` | Питание: 0=выкл, 1=вкл | 0 или 1 |

### Скрипт управления питанием

**Файл**: `system/repowerall.sh`

```bash
#!/bin/sh

hubctrl="/usr/simbox/bin/hub-ctrl"

# Поиск всех хабов в системе
hubs=`lsusb | grep DUB-H7 | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`
hubs2=`lsusb | grep 1a40:0101 | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`
hubs3=`lsusb | grep Terminus | grep -o -R "[0-9]* Device [0-9]*" | sed 's/ Device /:/g'`

hubs="$hubs $hubs2 $hubs3"

for hub in $hubs
do
    echo "HUB=$hub"
    
    # Получение списка портов
    ports=`lsusb -v -s $hub | grep -o -R "Port [0-9]: " | grep -o -R "[0-9]:" | sed 's/://g'`
    
    for port in $ports
    do
        # Извлечение bus и device
        b=`echo "$hub" | grep -o -R "[0-9]*:" | sed 's/://g'`
        d=`echo "$hub" | grep -o -R ":[0-9]*" | sed 's/://g'`
        
        # Выключение питания
        $hubctrl -b $b -d $d -P $port -p 0
        sleep 2
        
        # Включение питания
        $hubctrl -b $b -d $d -P $port -p 1
        sleep 2
    done
done
```

### Веб-интерфейс управления хабами

**Файл**: `www/simbox/hubs.php`

```php
// Управление питанием через веб-интерфейс
foreach($_POST['id'] as $v=>$adr) {
    @list($bus,$dev,$port)=explode(":",$adr);
    
    if (($dev>0)&&($port>0)) {
        // Выключение
        if ($onoff==0) 
            $cmd="/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 0";
        
        // Включение
        if ($onoff==1) 
            $cmd="/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 1";
        
        // Перезагрузка (выкл/вкл)
        if ($onoff==2) 
            $cmd="/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 0 && "
                ."/bin/sleep 2 && "
                ."/usr/simbox/bin/hub-ctrl -b $bus -d $dev -P $port -p 1";
        
        exec_delay($cmd);
    }
}
```

### Сценарии использования

1. **Перезависший модем** — полная перезагрузка через отключение питания
2. **Массовая перезагрузка** — цикл по всем портам всех хабов
3. **Диагностический режим** — отключение для безопасной перепрошивки

---

## 2. Ридеры SIM-карт

### Обзор

Система использует **внешние USB-ридеры SIM-карт** для:
- Чтения KI (ключей аутентификации)
- Клонирования SIM-карт
- Создания профилей для мультисим-адаптеров

### Поддерживаемые устройства

**Файл**: `wtss/wts.pas` (Pascal, legacy)

| Устройство | Тип | Интерфейс |
|------------|-----|-----------|
| **Dejian CardReader** | PC/SC | USB (ttyUSB) |
| **USI 2.0** | ISO 7816 | Serial |
| **R520m** | Phone cable | Serial |
| **R520s** | Service cable | Serial |
| **R520d** | LPT dongle | Parallel |
| **Emulator** | Comp128v1 | Software |

### Архитектура работы с ридерами

```
┌─────────────────────────────────────────────────────────┐
│                  SIM Card Reader                        │
│  ┌─────────────────────────────────────────────────────┐│
│  │  wtss/wts (Pascal) - основное приложение            ││
│  │  - Управление портом (SynaSer)                      ││
│  │  - GSM алгоритмы (Comp128v1)                        ││
│  │  - Атаки на KI (2R, 3R, 4R, 5R, Brute Force)       ││
│  └─────────────────────────────────────────────────────┘│
│                        │                                 │
│  ┌─────────────────────▼─────────────────────────────┐  │
│  │  svistok-aa/reader/ (C) - low-level драйвер       │  │
│  │  - reader_core.c/h - базовые операции             │  │
│  │  - emulator.c - эмулятор SIM                      │  │
│  │  - adapter.c - работа с адаптером                 │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Структура данных ридера

**Файл**: `svistok-aa/reader/reader_core.h`

```c
typedef struct rdr {
    char dev[DEVPATHLEN];           // Устройство (ttyUSB)
    char data_tty[DEVPATHLEN];      // Data-порт
    int data_fd;                    // File descriptor
    char *data_lock;                // Блокировка
    
    int timeout;                    // Таймаут (500ms)
    unsigned int connected;         // Флаг подключения
    
    char iccid[64];                 // ICCID карты
    char imsi[64];                  // IMSI
    char ki[64];                    // Найденный KI
    char spn[64];                   // Оператор
    
    int haspin;                     // Требуется PIN
} rdr_t;
```

### Веб-интерфейс ридеров

**Файл**: `www/simbox/readers.php`

```php
// Запуск процесса чтения KI
if(isset($_POST['findki'])) {
    foreach($_POST['id'] as $v=>$device) {
        $dataport = file_get_contents_def2(
            "/var/svistok/devices/$device.dataport", ""
        );
        
        // Запуск wts в фоновом режиме
        $cmd = 'sudo nice -n 19 ionice -c3 '
             . '/usr/simbox/wtss/wts '
             . '--svistokmode=1 '
             . '--device=reader '
             . '--speed=9600 '
             . '--ignorects '
             . '--port=' . $dataport . ' '
             . '--dev=' . $device . ' '
             . '> /tmp/reader_'.$device.'.log &';
        
        exec_delay($cmd);
    }
}
```

### Файлы состояния

```
/var/svistok/readers/
├── state/
│   ├── $device.status      # Статус чтения
│   ├── $device.iccid       # ICCID карты
│   └── $device.lock        # Блокировка устройства
└── sim/
    ├── $ICCID.imsi         # IMSI карты
    ├── $ICCID.ki           # Найденный KI
    ├── $ICCID.gsm          # GSM-лог (RAND-SRES пары)
    ├── $ICCID.result       # Результат (1000+код)
    └── $ICCID.log          # Полный лог операции
```

### Статусы операции

| Код | Значение |
|-----|----------|
| 1000 | Успешно, KI найден |
| 1001 | Ошибка чтения |
| 1002 | Неверный PIN |
| 1003 | Карта заблокирована |

---

## 3. Программирование KI в мультисим-адаптеры

### Типы адаптеров

| Тип | Название | Метод программирования |
|-----|----------|----------------------|
| **Type 9** | 9-е поколение | STK (SIM Toolkit) AT-команды |
| **Type 16** | SuperSIM 16-е поколение | CSIM APDU команды |

### Type 9: STK программирование

**Файл**: `system/set_ki.php`

```php
if ($adapter == "9") {
    echo "SET KI 9th generation\n";
    
    // Вход в режим программирования
    exec_at_command($dongle, 'AT^STGI=0,0');
    exec_at_command($dongle, 'AT^STGR=0,0,1,22');
    exec_at_command($dongle, 'AT^STGI=6,1');
    exec_at_command($dongle, 'AT^STGR=6,1,1,3');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Запись KI (32 hex символа)
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_ki) . '"');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Запись IMSI (18 цифр)
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_imsi) . '"');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Запись ICCID (20 цифр)
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_iccid) . '"');
    exec_at_command($dongle, 'AT^STGI=3,1');
    
    // Запись SMSC
    exec_at_command($dongle, 'AT^STGR=3,1,1,"' . bin2hex($dat_smsc) . '"');
    exec_at_command($dongle, 'AT^STGI=6,1');
    exec_at_command($dongle, 'AT^STGI=0,0');
    
    // Выбор профиля 3
    exec_at_command($dongle, 'AT^STGI=0,0');
    exec_at_command($dongle, 'AT^STGR=0,0,1,16');
    exec_at_command($dongle, 'AT^STGI=6,1');
    exec_at_command($dongle, 'AT^STGR=6,1,1,3');
    exec_at_command($dongle, 'AT^STGI=7,1');
    exec_at_command($dongle, 'AT^STGR=7,1,0,""');
    exec_at_command($dongle, 'AT^STGI=0,0');
    
    // Смена IMEI и перезагрузка
    system('/usr/sbin/asterisk -rx "dongle changeimei ' . $dongle . ' ' . $imei . '"');
    exec_at_command($dongle, 'AT+CFUN=1,1');
}
```

### Type 16: SuperSIM (CSIM APDU)

```php
if ($adapter == "16") {
    echo "SET KI Supersim 16th generation\n";
    
    // Подготовка данных в правильном формате
    $iccid = supersim_make_iccid($dat_iccid);  // 20 символов
    $imsi  = supersim_make_imsi($dat_imsi);    // 18 символов
    $ki    = supersim_make_ki($dat_ki);        // 32 символа
    $smsp  = supersim_make_smsp($dat_smsc);    // 24 символа
    
    // CSIM APDU команды для записи
    // Select DF
    exec_at_command($dongle, 'AT+CSIM=14,"A0A4000002A000"');
    
    // Write KI
    $apdu = build_ki_write_apdu($ki);
    exec_at_command($dongle, 'AT+CSIM=' . strlen($apdu) . ',"' . $apdu . '"');
    
    // Write IMSI
    $apdu = build_imsi_write_apdu($imsi);
    exec_at_command($dongle, 'AT+CSIM=' . strlen($apdu) . ',"' . $apdu . '"');
    
    // Write ICCID
    $apdu = build_iccid_write_apdu($iccid);
    exec_at_command($dongle, 'AT+CSIM=' . strlen($apdu) . ',"' . $apdu . '"');
    
    // Verify
    verify_ki($dongle, $imsi);
}
```

### Форматы данных

#### IMSI (18 символов)

```php
function supersim_make_imsi($imsi) {
    // Вход: "082905991259443683" (18 цифр)
    // Выход: "809250991524934638" (перестановка байт)
    
    $a = str_split($imsi);
    return $a[1].$a[0].$a[3].$a[2].$a[5].$a[4].$a[7].$a[6].
           $a[9].$a[8].$a[11].$a[10].$a[13].$a[12].
           $a[15].$a[14].$a[17].$a[16];
}
```

#### ICCID (20 символов)

```php
function supersim_make_iccid($iccid) {
    // Вход: "897019911107987336" (19 цифр)
    // Добавляем F: "897019911107987336F" (20)
    // Выход: перестановка байт
    
    if (strlen($iccid) == 19) $iccid .= "F";
    
    $a = str_split($iccid);
    return $a[1].$a[0].$a[3].$a[2].$a[5].$a[4].$a[7].$a[6].
           $a[9].$a[8].$a[11].$a[10].$a[13].$a[12].
           $a[15].$a[14].$a[17].$a[16].$a[19].$a[18];
}
```

### Поток программирования

```
┌─────────────────┐
│  Центральный    │
│  сервер (KI)    │
└────────┬────────┘
         │ HTTP
         │ new_ki.php
         ▼
┌─────────────────┐
│  system/new_ki  │
│  - Fetch KI     │
│  - Parse        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  system/set_ki  │
│  - Program      │
│    Type 9/16    │
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
└─────────────────┘
```

---

## 4. Эмуляция SIM-карты через ридер

### Концепция

Ридер SIM-карт может **эмулировать физическую SIM-карту** для модема через последовательный порт.

### Реализация

**Файл**: `svistok-aa/simnode/adiscovery_core.c`

```c
// Поиск ридеров в системе
void usbdevs_filelist(const char *filename, int vendor_id) {
    // Scan USB devices
    // Match vendor_id (1002 for Dejian)
    // Write to /var/svistok/lists/readers.list
}

// Обнаружение ридера
if (usbdevs_filelist("/var/svistok/lists/readers.list", 1002)) {
    alog(NULL, "Reader found");
    // Initialize reader
    // Connect to SIM
}
```

### Режимы работы

| Режим | Описание |
|-------|----------|
| **Reader** | Физический ридер с SIM |
| **Emulator** | Программная эмуляция Comp128v1 |
| **SimNode** | Сетевой эмулятор SIM |

### Протокол обмена

```
┌─────────────────┐         ┌─────────────────┐
│     Modem       │         │     Reader      │
│   (ttyUSB0)     │         │   (ttyUSB1)     │
└────────┬────────┘         └────────┬────────┘
         │                           │
         │  AT+CSIM=<len>,"<apdu>"   │
         │──────────────────────────>│
         │                           │
         │                    ┌──────▼──────┐
         │                    │  SIM Card   │
         │                    │  APDU Proc  │
         │                    └──────┬──────┘
         │                           │
         │  +CSIM: <len>,"<resp>"    │
         │<──────────────────────────│
         │                           │
```

### Команды эмуляции

```pascal
// wtss/wts.pas - режим эмулятора
if Value = 'emul1' then begin
    // Comp128v1 эмулятор
    // KI хранится в памяти
    // Отвечает на RAND запросы
    Device := DEVICE_EMULATOR;
end;

if Value = 'reader' then begin
    // Физический ридер
    // Dejian, USI 2.0
    Device := DEVICE_READER;
end;
```

### Файлы эмуляции

```
/var/svistok/sim/reader/
├── $ICCID.gsm      # RAND-SRES пары для атак
├── $ICCID.res      # Результаты вычислений
└── $ICCID.log      # Лог операций
```

---

## 5. Безопасность и ограничения

### Критические уязвимости

1. **KI передаётся открыто**
   - По HTTP (simserver:8122)
   - В логах (`/tmp/reader_*.log`)
   - В файлах (`/var/svistok/readers/sim/$ICCID.ki`)

2. **Нет аутентификации**
   - Доступ к ридерам без проверки
   - Команды выполняются от root (sudo)

3. **Физический доступ**
   - USB-порты незащищены
   - Ридеры доступны из веб-интерфейса

### Рекомендации

1. **Шифрование KI**
   ```php
   // Вместо plaintext
   file_put_contents("/var/svistok/readers/sim/$ICCID.ki", $ki);
   
   // Использовать шифрование
   file_put_contents("/var/svistok/readers/sim/$ICCID.ki.enc", 
                     openssl_encrypt($ki, 'AES-256-CBC', $key));
   ```

2. **Ограничение sudo**
   ```bash
   # /etc/sudoers
   asterisk ALL=(ALL) NOPASSWD: /usr/simbox/bin/hub-ctrl
   asterisk ALL=(ALL) NOPASSWD: /usr/sbin/asterisk
   ```

3. **Изоляция ридеров**
   - Отдельная VLAN для ридеров
   - Физический доступ только из защищённой зоны

---

## 6. Глоссарий

| Термин | Определение |
|--------|-------------|
| **KI** | Key Identifier, криптографический ключ SIM (128 бит) |
| **IMSI** | International Mobile Subscriber Identity |
| **ICCID** | Integrated Circuit Card Identifier |
| **APDU** | Application Protocol Data Unit (ISO 7816) |
| **CSIM** | CDMA SIM APDU команды |
| **STK** | SIM Toolkit (GSM 11.14) |
| **Comp128v1** | Алгоритм аутентификации GSM |

---

*Документ создан через /legacy анализ — 2026-03-03*
