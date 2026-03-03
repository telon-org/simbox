# DDD: chan_svistok — Asterisk Module Extension

**Дата**: 2026-03-03  
**Статус**: APPROVED  
**Тип**: Document-Driven Development  
**Модуль**: chan_svistok (надстройка над chan_dongle)

---

## 01. Business Overview

### Назначение

**chan_svistok** — это кастомизированная версия модуля chan_dongle для Asterisk PBX, разработанная специально для управления GSM SIM-боксами с централизованным управлением через simserver.

### Бизнес-ценность

| Возможность | Бизнес-выгода |
|-------------|---------------|
| Централизованное управление | Масштабирование на множество SIM-боксов |
| Логирование всех событий | Аудит и биллинг вызовов |
| Интеграция с simserver | Автоматическое управление KI/IMSI |
| Поддержка мультисим-адаптеров | Снижение затрат на SIM-карты |
| Анти-детект функции | Продление жизни SIM-карт |

### Заинтересованные стороны

| Стейкхолдер | Интерес |
|-------------|---------|
| **Операторы** | Мониторинг состояния модемов |
| **Финансы** | Биллинг и учёт затрат |
| **Техподдержка** | Диагностика проблем |
| **Разработчики** | Расширение функциональности |

---

## 02. Архитектура

### Отношение chan_svistok к chan_dongle

```
┌─────────────────────────────────────────────────────────┐
│                    chan_dongle (base)                    │
│  Оригинал: http://www.e1550.mobi (bg_one@mail.ru)       │
│  - Базовый драйвер для Huawei USB-модемов               │
│  - AT-команды, SMS, USSD, голосовые вызовы              │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   chan_svistok (fork)                    │
│  Версия: 1.1200                                          │
│  Модификации:                                            │
│  + adiscovery_svistok.c (SIM discovery)                 │
│  + Интеграция с simserver:8122                          │
│  + Расширенное логирование                              │
│  + Поддержка мультисим-адаптеров                        │
└─────────────────────────────────────────────────────────┘
```

### Ключевые модификации

**Файл**: `chan_dongle.c`

```c
// Версия chan_svistok
char svistok_version[64] = "1.1200";

// Интеграция adiscovery
#include "simnode/adiscovery_svistok.c"

// Вызов adiscovery при инициализации устройства
r = pvt_adiscovery(pvt);
```

---

## 03. adiscovery — Обнаружение SIM

### Назначение

**adiscovery** (Asterisk Discovery) — механизм обнаружения и идентификации SIM-карт в USB-модемах.

### Компоненты adiscovery

```
svistok-aa/simnode/
├── adiscovery_core.c       # Базовая логика обнаружения
├── adiscovery_core_new.c   # Обновлённая версия
├── adiscovery_simnode.c    # Standalone утилита
├── adiscovery_svistok.c    # Интеграция с chan_svistok
└── adiscovery_test.c       # Тестовый режим
```

### adiscovery_svistok.c

**Путь**: `svistok-aa/simnode/adiscovery_svistok.c`

```c
#include "adiscovery_core.c"

// Логирование
void alog(FILE *fd, char *fmt, ...) {
    char buf[512];
    va_list ap;
    va_start(ap, fmt);
    vsprintf(buf, fmt, ap);
    va_end(ap);
    
    if (fd == NULL) {
        ast_verb(3, "%s", buf);  // Вывод в Asterisk
    } else {
        fprintf(fd, "%s", buf);  // Вывод в файл
    }
}

// Обнаружение устройства для private structure
static int pvt_adiscovery(struct pvt *pvt) {
    if (CONF_UNIQ(pvt, data_tty)[0] != 0) {
        // Копирование data_tty
        ast_copy_string(PVT_STATE(pvt, data_tty), 
                       CONF_UNIQ(pvt, data_tty),
                       sizeof(PVT_STATE(pvt, data_tty)));
        
        // Получение audioport
        return usbdev_get_audioport(CONF_UNIQ(pvt, data_tty),
                                    PVT_STATE(pvt, audio_tty));
    }
    return 0;
}
```

### adiscovery_core.c — База данных устройств

**Определения устройств**:

```c
defdev_t defdevs[] = {
    // {model, mode, idVendor, idProduct, interfaces, dataport, audioport}
    
    // Huawei E1550 (work mode)
    {200, 1, 0x12d1, 0x1001, {
        {1, {0x01, 0x00, 0x00, 0x81, 0x82}},  // Interface 0
        {1, {0x00, 0x02, 0x00, 0x83}},         // Interface 1
        {0}
    }, 2, 1},
    
    // Huawei E1550 (diag mode)
    {1550, 2, 0x12d1, 0x1003, {...}, 1, -1},
    
    // Huawei E1550 (normal mode)
    {1550, 3, 0x12d1, 0x14ac, {...}, 0, -1},
    
    // Huawei E173
    {173, 3, 0x12d1, 0x140c, {...}, 0, -1},
    
    // PL2303 (SIM reader)
    {1616, 1, 0x67b, 0x2303, {...}, 0, 0}
};
```

### adiscovery_simnode.c — Standalone утилита

**Запуск обнаружения**:

```c
int main(int argc, char *argv[]) {
    sysdevs_find();      // Поиск системных устройств
    usbdevs_find();      // Поиск USB устройств
    
    while (1) {
        sleep(1);
        sysdevs_find();
        usbdevs_find();
        
        // Логирование в файлы
        sysdevs_log("/var/svistok/lists/sysdevs.list");
        usbdevs_log("/var/svistok/lists/usbdevs_all.list", -1);
        usbdevs_log("/var/svistok/lists/usbdevs_active.list", 1);
        usbdevs_log("/var/svistok/lists/usbdevs_diag.list", 2);
        usbdevs_log("/var/svistok/lists/usbdevs_unknown.list", 0);
        
        // Генерация списков устройств
        usbdevs_filelist("/var/svistok/lists/devices_diag.list", 2);
        usbdevs_filelist("/var/svistok/lists/readers.list", 1002);
    }
    return 0;
}
```

### Процесс обнаружения

```
┌─────────────────┐
│  USB Device     │
│  Plug In        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  sysdevs_find() │
│  Scan /sys/bus/ │
│  usb/devices    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  usbdevs_find() │
│  Match vendor/  │
│  product ID     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Parse Endpoints│
│  /ep_XX files   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Match against  │
│  defdevs[]      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Identify:      │
│  - Model        │
│  - Mode         │
│  - Data port    │
│  - Audio port   │
└─────────────────┘
```

### Типы устройств

| Mode | Значение | Описание |
|------|----------|----------|
| 0 | Unknown | Неопознанное устройство |
| 1 | Work | Рабочий режим (голосовые вызовы) |
| 2 | Diag | Диагностический режим (прошивка) |
| 3 | Normal | Нормальный режим (AT-команды) |
| 1002 | Reader | SIM-ридер (Dejian, PL2303) |

---

## 04. Интеграция с simserver

### Централизованное управление

**simserver:8122** — центральный сервер управления SIM-боксами.

### Логирование событий

#### SMS/USSD логирование

**Файл**: `system/send.sh`

```bash
#!/bin/bash
TYPE=$1      # sms, ussd, ussdend
DONGLE=$3
NUMBER=$4
TEXT=$5

DONGLEIMSI=`cat /var/svistok/dongles/state/$DONGLE.imsi`
NOW=`date +"%Y-%m-%d %H:%M:%S"`
TEXT64=`echo "$TEXT" | base64 --wrap=0`

if [ "$TYPE" == "sms" ]; then
    # Логирование
    echo "SMS|O|$NOW|$DONGLE|$DONGLEIMSI|$NUMBER|$TEXT64" >> \
         /var/svistok/sim/log/$DONGLEIMSI.smsussd2
    
    # Отправка через Asterisk
    /usr/sbin/asterisk -rx "dongle sms $DONGLE $NUMBER $TEXT"
fi

if [ "$TYPE" == "ussd" ]; then
    echo "USSD|O|$NOW|$DONGLE|$DONGLEIMSI|$NUMBER|$TEXT64" >> \
         /var/svistok/sim/log/$DONGLEIMSI.smsussd2
    
    /usr/sbin/asterisk -rx "dongle ussd $DONGLE $NUMBER"
fi
```

#### Логирование вызовов

**Исходящие вызовы**: `system/svistok/callendout.sh`

```bash
URL="http://simserver:8122/svistok/callendout.php?
    numberb=$NUMBERBe&
    numbera=$NUMBERAe&
    numbermy=$NUMBERMYe&
    serial=$DONGLES&
    dongle=$DONGLENAME&
    gateway=$IAXME&
    durationsec=$TOTALSEC&
    billsec=$BILLSEC&
    dialstatus=$DIALSTATUS&
    imei=$DONGLEIMEI&
    imsi=$DONGLEIMSI&
    lac=$LAC&
    cell=$CELL&
    end_status=$END_STATUS&
    cc_cause=$CC_CAUSE&
    end_party=$END_PARTY&
    spec=$spec&
    vip=$vip&
    pdd=$pdd&
    uid=$uid"

curl "$URL"
```

**Входящие вызовы**: `system/svistok/callendin.sh`

```bash
URL="http://simserver:8122/svistok/callendin.php?
    numberb=$NUMBERBe&
    numbermy=$NUMBERMYe&
    serial=$DONGLES&
    dongle=$DONGLENAME&
    gateway=$IAXME&
    durationsec=$TOTALSEC&
    billsec=$BILLSEC&
    dialstatus=$DIALSTATUS&
    imei=$DONGLEIMEI&
    imsi=$DONGLEIMSI&
    lac=$LAC&
    cell=$CELL&
    end_status=$END_STATUS"

curl "$URL"
```

### Попытки вызовов

**Файл**: `system/trycall.sh`

```bash
#!/bin/bash
NUMBERA=$1
NUMBERB=$2
IMSI=$3

curl "http://simserver:8122/trycall.php?
    numbera=$NUMBERA&
    numberb=$NUMBERB&
    imsi=$IMSI"
```

---

## 05. Файловая структура

### Состояния и логи

```
/var/svistok/
├── dongles/
│   └── state/
│       ├── $dongle.imsi       # IMSI модема
│       ├── $dongle.iccid      # ICCID SIM
│       ├── $dongle.imei       # IMEI модема
│       └── $dongle.str_state  # Строковое состояние
├── sim/
│   └── log/
│       ├── $imsi.smsussd2     # SMS/USSD лог
│       ├── $imsi.calllog      # История вызовов
│       └── $imsi.rasp_imsi    # Распознавание речи
└── lists/
    ├── sysdevs.list          # Системные устройства
    ├── usbdevs_all.list      # Все USB устройства
    ├── usbdevs_active.list   # Активные устройства
    ├── usbdevs_diag.list     # Устройства в diag режиме
    ├── usbdevs_unknown.list  # Неопознанные устройства
    ├── devices_diag.list     // Скрипт для diag
    └── readers.list          # SIM-ридеры
```

### Формат логов

#### SMS/USSD лог

```
Формат: TYPE|DIRECTION|TIMESTAMP|DONGLE|IMSI|NUMBER|TEXT(base64)

Пример:
SMS|O|2026-03-03 10:15:30|dongle01|250201234567890|+79991234567|SGVsbG8gV29ybGQ=
USSD|O|2026-03-03 10:16:00|dongle01|250201234567890|*105#|QmFsYW5jZTogMTAwIFJVQg==
```

#### Лог вызовов

| Поле | Описание |
|------|----------|
| numberb | B-party (куда звонили) |
| numbera | A-party (кто звонил) |
| numbermy | Наш номер (SIM) |
| dongle | Имя устройства |
| imsi | IMSI SIM-карты |
| imei | IMEI модема |
| durationsec | Общая длительность |
| billsec | Биллинговая длительность |
| dialstatus | Статус вызова (ANSWER, NOANSWER, BUSY) |
| lac | Location Area Code |
| cell | Cell ID |
| end_status | Статус завершения |

---

## 06. Build и установка

### Сборка chan_svistok

**Makefile**:

```makefile
PROJM = chan_dongle.so

chan_donglem_so_OBJS = app.o at_command.o at_parse.o at_queue.o \
    at_read.o at_response.o chan_dongle.o channel.o char_conv.o \
    cli.o helpers.o manager.o memmem.o ringbuffer.o cpvt.o \
    dc_config.o pdu.o mixbuffer.o pdiscovery.o

CFLAGS = -g -O2 -O6 -I$(srcdir) -D_GNU_SOURCE \
         -DASTERISK_VERSION_NUM=110000 \
         -fvisibility=hidden -fPIC -Wall -Wextra

all: chan_dongle.so

install: all
    $(INSTALL) -m 755 chan_dongle.so /usr/lib/asterisk/modules/
```

### Компиляция с adiscovery

```bash
# Конфигурация
./configure --with-asterisk=/usr/src/asterisk-11

# Сборка
make

# Установка
make install

# Перезагрузка Asterisk
asterisk -rx "module reload chan_dongle.so"
```

### Проверка установки

```bash
# Проверка версии
asterisk -rx "dongle show version"
# Ожидается: svistok_version = 1.1200

# Проверка устройств
asterisk -rx "dongle show devices"

# Проверка логов
tail -f /var/svistok/sim/log/*.smsussd2
```

---

## 07. API для внешней интеграции

### simserver:8122 endpoints

| Endpoint | Метод | Описание |
|----------|-------|----------|
| `/svistok/callendout.php` | GET | Завершение исходящего вызова |
| `/svistok/callendin.php` | GET | Завершение входящего вызова |
| `/svistok/calltry.php` | GET | Попытка вызова |
| `/trycall.php` | GET | Проверка возможности вызова |
| `/sms/getsmsout.php` | GET | Получение исходящих SMS |
| `/svistok/foundgettoday.php` | GET | Получение найденных сегодня |

### Формат запросов

**Завершение вызова**:
```
GET /svistok/callendout.php?
    numberb=79991234567&
    numbera=78121234567&
    imsi=250201234567890&
    billsec=120&
    dialstatus=ANSWER
```

**Попытка вызова**:
```
GET /svistok/calltry.php?
    numbera=78121234567&
    numberb=79991234567&
    imsi=250201234567890&
    spec=VIP
```

---

## 08. Безопасность

### Уязвимости

1. **HTTP без шифрования** — все данные на simserver передаются открыто
2. **Нет аутентификации** — любой может отправить запрос на simserver
3. **Базовый кодирование SMS** — только base64 (не шифрование)
4. **Логи в открытом виде** — /var/svistok/sim/log/ доступен для чтения

### Рекомендации

1. Включить HTTPS для simserver
2. Добавить API ключи для аутентификации
3. Шифровать чувствительные данные в логах
4. Ограничить доступ к файлам логов (chmod 600)

---

## 10. Дополнительные компоненты chan_svistok

### share.c — Общие функции и блокировки

**Файл**: `svistok-aa/share.c`

#### Блокировка pvt (private structure)

```c
// Отслеживание блокировок с записью в файлы
int mutex_lock_pvt_e(struct pvt* pvt, const char* filename, int lineno) {
    pvt->lock_start = (long)time(NULL);
    
    // Запись в файлы состояния для отладки
    putfilel("dongles/state", PVT_ID(pvt), "lock_start", pvt->lock_start);
    putfiles("dongles/state", PVT_ID(pvt), "lock_filename", filename);
    putfilei("dongles/state", PVT_ID(pvt), "lock_lineno", lineno);
    
    return ast_mutex_lock(&pvt->lock);
}

int mutex_unlock_pvt_e(struct pvt* pvt, const char* filename, int lineno) {
    pvt->lock_start = 0;
    putfilel("dongles/state", PVT_ID(pvt), "lock_start", 0);
    
    return ast_mutex_unlock(&pvt->lock);
}
```

#### Чтение настроек и лимитов

```c
void readpvtsettings(struct pvt* pvt) {
    // Чтение мягких лимитов (0-5 = 6 временных зон)
    getfilei("sim/limits", pvt->imsi, "limit_soft.0", &PVT_STAT(pvt, limit_soft[0]));
    getfilei("sim/limits", pvt->imsi, "limit_soft.1", &PVT_STAT(pvt, limit_soft[1]));
    // ... до 5
    
    // Чтение жёстких лимитов
    getfilei("sim/limits", pvt->imsi, "limit_hard.0", &PVT_STAT(pvt, limit_hard[0]));
    // ...
    
    // Алгоритмы (codec preferences)
    getfilei("sim/settings", pvt->imsi, "alg.0", &PVT_STAT(pvt, alg[0]));
    // ...
    
    // No-diff зоны (где не менять SIM)
    getfilei("sim/settings", pvt->imsi, "nodiff.0", &PVT_STAT(pvt, nodiff[0]));
    // ...
}

void readpvtlimits(struct pvt* pvt) {
    // Чтение текущих лимитов по зонам
    getfilei("sim/limits", pvt->imsi, "limit.0", &PVT_STAT(pvt, limit[0]));
    getfilei("sim/limits", pvt->imsi, "limit.1", &PVT_STAT(pvt, limit[1]));
    // ... до 5
}
```

### stat.c — Статистика вызовов

**Файл**: `svistok-aa/stat.c`

#### Этапы вызова

```c
// Начало вызова
void v_stat_call_start(struct pvt *pvt) {
    PVT_STAT(pvt, stat_call_start) = (long)time(NULL);
    PVT_STAT(pvt, stat_call_connected) = 0;
    PVT_STAT(pvt, stat_call_fas) = 0;         // First Answer Signal
    PVT_STAT(pvt, stat_call_pddc) = 0;        // Post Dialing Delay Complete
    PVT_STAT(pvt, stat_call_saved) = 0;
    PVT_STAT(pvt, stat_call_response) = 0;
    
    putfilei("sim/state", pvt->imsi, "busy", 1);
    ast_verb(3, "TEST L-START %s\n", PVT_ID(pvt));
}

// Ответ (connected)
void v_stat_call_connected(struct pvt *pvt) {
    PVT_STAT(pvt, stat_call_connected) = (long)time(NULL);
    PVT_STAT(pvt, stat_call_saved) = (long)time(NULL);
    
    if (PVT_STAT(pvt, stat_call_fas) == 0)
        PVT_STAT(pvt, stat_call_fas) = (long)time(NULL);
    if (PVT_STAT(pvt, stat_call_pddc) == 0)
        PVT_STAT(pvt, stat_call_pddc) = (long)time(NULL);
    
    putfilei("sim", pvt->imsi, "stat_call_connected", PVT_STAT(pvt, stat_call_connected));
    putfilei("sim/state", pvt->imsi, "state_busy", 1);
}

// Завершение
void v_stat_call_end(struct pvt *pvt, int duration) {
    PVT_STAT(pvt, stat_call_end) = (long)time(NULL);
    putfilei("sim", pvt->imsi, "stat_call_end", PVT_STAT(pvt, stat_call_end));
    
    // Финальная запись лимитов
    limits_final(pvt, duration);
    
    // Биллинг
    billing_save(pvt, duration);
}
```

#### Биллинг

```c
void billing_save(struct pvt *pvt, long int duration) {
    long int seconds;
    char dn[256];
    
    datenow(dn);  // Получение текущей даты
    
    if ((duration > 0) && (duration < 2000)) {
        if (PVT_STAT(pvt, billing_pay) == 1) {
            // Платный вызов
            getfilel_def("sim/statistics/billing", dn, 
                        PVT_STAT(pvt, billing_direction), &seconds, 0);
            seconds += duration;
            putfilel("sim/statistics/billing", dn, 
                    PVT_STAT(pvt, billing_direction), seconds);
        } else {
            // Системный/бесплатный вызов
            getfilel_def("sim/statistics/billing", dn, "system", &seconds, 0);
            seconds += duration;
            putfilel("sim/statistics/billing", dn, "system", seconds);
        }
    }
}
```

### limits.c — Управление лимитами

**Файл**: `svistok-aa/limits.c`

#### Промежуточная запись лимитов

```c
void limits_temp(struct pvt *pvt) {
    readpvtlimits(pvt);
    
    // Уменьшение лимита на время звонка
    PVT_STAT(pvt, limit[PVT_STAT(pvt, limitnum)]) -= 
        ((long)time(NULL)) - PVT_STAT(pvt, stat_call_saved);
    
    PVT_STAT(pvt, stat_call_saved) = (long)time(NULL);
    writepvtlimits(pvt);
    
    // Проверка жёсткого лимита
    if ((PVT_STAT(pvt, limittype) == '_') || (PVT_STAT(pvt, limittype) == '-')) {
        if (PVT_STAT(pvt, limit[PVT_STAT(pvt, limitnum)]) <= 0) {
            ast_verb(3, "PEREBOR PO LIMITU %s\n", PVT_ID(pvt));
            
            // Принудительное завершение исходящих вызовов
            AST_LIST_TRAVERSE(&pvt->chans, cpvt, entry) {
                if (cpvt->dir == CALL_DIR_OUTGOING) {
                    queue_hangup(cpvt->channel, 0);
                }
            }
        }
    }
}
```

#### Финальная запись лимитов

```c
void limits_final(struct pvt *pvt, int duration) {
    readpvtlimits(pvt);
    
    // Возврат временного вычета
    PVT_STAT(pvt, limit[PVT_STAT(pvt, limitnum)]) += 
        PVT_STAT(pvt, stat_call_saved) - PVT_STAT(pvt, stat_call_connected);
    
    if (PVT_STAT(pvt, limitnum) != '_') {
        // Обычное округление
        PVT_STAT(pvt, limit[PVT_STAT(pvt, limitnum)]) -= duration;
    } else {
        // Округление до минуты с +5 секундами
        PVT_STAT(pvt, limit[PVT_STAT(pvt, limitnum)]) -= 
            ceil(((float)duration + 5) / 60) * 60;
    }
    
    PVT_STAT(pvt, limitnum) = 0;
    writepvtlimits(pvt);
}
```

### share_mysql.c — MySQL интеграция

**Файл**: `svistok-aa/share_mysql.c`

```c
// Конфигурация MySQL (hardcoded!)
MYSQL *mysql;
char mysql_host = "localhost";
char mysql_user = "svistok";
char mysql_pass = "svistok4385";  // ⚠️ SECURITY ISSUE
char mysql_db = "svistok";

void a_mysql_connect() {
    mysql = mysql_init(0);
    if (!mysql) {
        st_verb(3, "MYSQL: cannot create socket (%s)", mysql_error(mysql));
        return;
    }
    
    if (!(mysql_real_connect(mysql, mysql_host, mysql_user, 
                            mysql_pass, mysql_db, 0, NULL, 0))) {
        st_verb(3, "MYSQL: cannot connect (%s)", mysql_error(mysql));
        mysql = NULL;
        return;
    }
}
```

**Примечание**: Функции `mysql_getfilei`, `mysql_getfiles` и др. существуют, но в основном используется файловое хранилище.

---

## 11. Файлы состояния (State Files)

### Dongle State

```
/var/svistok/dongles/state/
├── $dongle.lock_start       # Timestamp начала блокировки
├── $dongle.lock_filename    # Файл, взявший блокировку
├── $dongle.lock_lineno      # Строка кода
├── $dongle.imsi             # IMSI SIM
├── $dongle.imei             # IMEI модема
├── $dongle.serial           # Серийный номер
├── $dongle.iccid            # ICCID SIM
├── $dongle.model            # Модель модема
├── $dongle.manufacturer     # Производитель
├── $dongle.firmware         # Версия прошивки
├── $dongle.audio            # Audio порт (ttyUSB*)
├── $dongle.data             # Data порт (ttyUSB*)
├── $dongle.net              # Network интерфейс
└── $dongle.dev              # Device path
```

### SIM State

```
/var/svistok/sim/
├── state/
│   └── $imsi.busy           # Флаг занятости (0/1)
├── statistics/
│   ├── $imsi.stat_call_start       # Timestamp начала
│   ├── $imsi.stat_call_connected   # Timestamp ответа
│   ├── $imsi.stat_call_end         # Timestamp завершения
│   ├── $imsi.stat_call_fas         # First Answer Signal
│   ├── $imsi.stat_call_pddc        # Post Dial Delay Complete
│   └── billing/
│       ├── $DATE.bee_spb    # Beeline SPb секунды
│       ├── $DATE.meg_msk    # MegaFon Moscow
│       └── $DATE.system     # Системные вызовы
└── limits/
    ├── $imsi.limit.0-5      # Текущие лимиты (6 зон)
    ├── $imsi.limit_soft.0-5 # Мягкие лимиты
    └── $imsi.limit_hard.0-5 # Жёсткие лимиты
```

### Лимитные зоны

| Зона | Описание | Пример |
|------|----------|--------|
| 0 | Ночь (00:00-06:00) | limit.0 |
| 1 | Утро (06:00-09:00) | limit.1 |
| 2 | День (09:00-18:00) | limit.2 |
| 3 | Вечер (18:00-23:00) | limit.3 |
| 4 | Выходные | limit.4 |
| 5 | Праздники | limit.5 |

---

## 12. TODO List (из TODO.txt)

### Выполнено

- [x] Command queue / serialization (r45, 27.11.2010)
- [x] Call waiting handling (r45, 27.11.2010)
- [x] Device files locking (r106, 17.12.2010)
- [x] SMS PDU mode / Unicode (r72-r75, 05-06.12.2010)
- [x] Automatic device discovery by IMEI/IMSI (r150, 08.01.2011)
- [x] DTMF duplication fix (r145, 08.01.2011)
- [x] Reconfigure on fly (r140, 07.01.2011)
- [x] CLI commands: show version, restart, sms, ussd

### Открытые задачи

- [ ] Extended device name for DEVICE_STATE()
- [ ] Automatic gain control (speex)
- [ ] LED control
- [ ] SMS receive with active voice call (full support)
- [ ] Remote side alerting detection (GSM 02.40)
- [ ] Volume settings from dialplan
- [ ] Response timeout handling

---

## 13. Безопасность (обновлено)

### Критические уязвимости

1. **MySQL пароль в коде**
   ```c
   char mysql_pass = "svistok4385";  // share_mysql.c
   ```

2. **Блокировки в файлах**
   ```
   /var/svistok/dongles/state/$dongle.lock_*
   ```
   Доступны для чтения всем процессам

3. **Лимиты в открытом виде**
   ```
   /var/svistok/sim/limits/$imsi.limit.*
   ```

### Рекомендации

1. Вынести MySQL credentials в конфиг
2. Шифровать чувствительные файлы
3. Ограничить права доступа (chmod 600)

---

## 14. Связанные документы

| Документ | Связь |
|----------|-------|
| [SDD: chan_dongle](../sdd-chan-dongle/) | Базовый модуль |
| [SDD: SIM Management](../sdd-sim-management/) | Лимиты и настройки SIM |
| [ADR-001](../adr-001-file-based-state/): File-Based State | Файловое хранилище |
| [Implementation Details](../legacy/understanding/implementation-details.md) | Технические детали |

---

*Generated by /legacy analysis — 2026-03-03*  
*Updated with svistok-aa deep analysis*
