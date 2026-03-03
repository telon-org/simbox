# DDD: Ubuntu Kernel Patches for Huawei Modems

**Дата**: 2026-03-03  
**Статус**: DRAFT  
**Тип**: Document-Driven Development  
**Модуль**: Kernel Patches (USB Serial)

---

## 01. Business Overview

### Назначение

Модификации ядра Ubuntu для поддержки увеличенного количества USB-последовательных портов, необходимых для работы с множественными GSM-модемами Huawei в SIM-боксах.

### Бизнес-ценность

| Возможность | Бизнес-выгода |
|-------------|---------------|
| Поддержка 1022 портов | Масштабирование до 1000+ модемов |
| Совместимость с Huawei | Работа с популярными модемами |
| Модификация option.c | Поддержка специфичных устройств |
| Отладочные выводы | Диагностика проблем |

### Заинтересованные стороны

| Стейкхолдер | Интерес |
|-------------|---------|
| **Системные администраторы** | Стабильность драйверов |
| **Разработчики** | Отладка USB-устройств |
| **Операторы** | Поддержка большого количества модемов |

---

## 02. Технические изменения

### serial.h — Увеличение количества портов

**Файл**: `kernel/diff/serial.h` → `kernel/new/serial.h`

#### Изменение 1: SERIAL_TTY_MINORS

```c
// Было (стандартное ядро):
#define SERIAL_TTY_MINORS    254
#define SERIAL_TTY_NO_MINOR  255

// Стало (патченное ядро):
#define SERIAL_TTY_MINORS    1022    /* loads of devices :) */
#define SERIAL_TTY_NO_MINOR  1023    /* No minor was assigned */
```

**Обоснование**: Стандартное ограничение в 254 устройства недостаточно для крупных инсталляций SIM-боксов.

#### Изменение 2: Тип данных minor

```c
// Было:
struct usb_serial_port {
    unsigned char number;
    unsigned char minor;
    // ...
};

// Стало:
struct usb_serial_port {
    unsigned int number;
//  unsigned char number;  // закомментировано
    
    // ...
    unsigned int minor;
//  unsigned char minor;   // закомментировано
};
```

**Обоснование**: `unsigned char` (0-255) недостаточно для 1022 устройств, требуется `unsigned int`.

#### Изменение 3: minor в usb_serial

```c
// Было:
struct usb_serial {
    unsigned char minor;
    // ...
};

// Стало:
struct usb_serial {
    unsigned int minor;
//  unsigned char minor;  // закомментировано
    // ...
};
```

### option.c — Отладочные выводы

**Файл**: `kernel/diff/option.c`

#### Удаление отладочного кода

```diff
1505d1502
< 	{
1507,1509d1503
< //		usb_make_path(urb->dev,dp,sizeof(dp));
< //		err("%s: error %d (device=%s)", __func__, status,dp);
< 	}
```

**Обоснование**: Удалены закомментированные отладочные выводы для уменьшения размера кода.

---

## 03. Diff файлы

### serial.diff

**Путь**: `kernel/diff/serial.diff`

```diff
--- serial.h.old
+++ serial.h
@@ -22,3 +22,3 @@
-#define SERIAL_TTY_MINORS	254
-#define SERIAL_TTY_NO_MINOR	255
+#define SERIAL_TTY_MINORS	1022
+#define SERIAL_TTY_NO_MINOR	1023
 
@@ -86,2 +86,2 @@
-	unsigned char		number;
+	unsigned int		number;
 
@@ -163,3 +162,3 @@
-	unsigned char		minor;
+	unsigned int		minor;
```

### option.diff

**Путь**: `kernel/diff/option.diff`

```diff
--- option.c
+++ option.c
@@ -1465,3 +1464,2 @@
-//	char dp[32];
-
@@ -1505,6 +1502,2 @@
-	{
-//		usb_make_path(urb->dev,dp,sizeof(dp));
-//		err("%s: error %d (device=%s)", __func__, status,dp);
-	}
```

---

## 04. Структура директорий

```
kernel/
├── diff/                    # Diff файлы патчей
│   ├── serial.diff          # Патч для serial.h
│   ├── option.diff          # Патч для option.c
│   ├── option.c             # Модифицированная версия
│   ├── serial.h             # Новая версия serial.h
│   └── d/                   # Дополнительные diff
├── new/                     # Новые файлы
│   ├── serial.h             # Новая версия заголовка
│   └── drivers/             # Драйверы
├── x64/                     # x64 специфичные файлы
│   └── serial.h             # serial.h для x64
└── r/                       # Резервные/старые файлы
```

---

## 05. Применение патчей

### Для ядра Ubuntu

```bash
# 1. Скачать исходники ядра
apt-get source linux-image-$(uname -r)

# 2. Применить патч serial.h
cd linux-*/drivers/usb/serial/
cp /usr/simbox/kernel/new/serial.h .

# 3. Применить патч option.c
cp /usr/simbox/kernel/diff/option.c .

# 4. Собрать ядро
cd /usr/src/linux-*/
make -j$(nproc)
make modules_install
make install

# 5. Перезагрузиться
reboot
```

### Альтернативно: patch command

```bash
# Применить serial.diff
cd /usr/src/linux-*/drivers/usb/serial/
patch < /usr/simbox/kernel/diff/serial.diff

# Применить option.diff
patch < /usr/simbox/kernel/diff/option.diff
```

---

## 06. Проверка установки

### Количество доступных портов

```bash
# Проверка количества устройств
cat /sys/bus/usb-serial/devices | wc -l

# Должно поддерживать до 1022
ls -la /dev/ttyUSB* | wc -l
```

### Версия драйвера option

```bash
# Информация о драйвере
modinfo option

# Должно показывать:
# filename:       /lib/modules/.../kernel/drivers/usb/serial/option.ko
# version:        v0.7.2
# description:    USB Driver for GSM modems
# author:         Matthias Urlichs <smurf@smurf.noris.de>
```

### Поддерживаемые устройства

```bash
# Проверка поддерживаемых устройств
modinfo option | grep -E "0x12D1|0x0AF0"

# Должны быть:
# Huawei: 0x12D1 (E173, K4505, K3765, K4605)
# Option: 0x0AF0 (various models)
```

---

## 07. Поддерживаемые устройства

### Huawei

| Модель | Vendor ID | Product ID | Статус |
|--------|-----------|------------|--------|
| E173 | 0x12D1 | 0x140C | ✅ |
| K4505 | 0x12D1 | 0x1464 | ✅ |
| K3765 | 0x12D1 | 0x1465 | ✅ |
| K4605 | 0x12D1 | 0x14C6 | ✅ |

### Option Inc.

| Модель | Vendor ID | Product ID |
|--------|-----------|------------|
| COLT | 0x0AF0 | 0x5000 |
| RICOLA | 0x0AF0 | 0x6000 |
| RICOLA Light | 0x0AF0 | 0x6100 |
| RICOLA Quad | 0x0AF0 | 0x6200 |
| COBRA | 0x0AF0 | 0x6500 |
| VIPER | 0x0AF0 | 0x6600 |

### Другие

| Производитель | Vendor ID | Продукты |
|---------------|-----------|----------|
| Quanta | 0x0408 | Q101, Q111, GLX, GKE, GLE |
| YISO | 0x0EAB | U893 |
| Novatel Wireless | 0x1410 | Various |

---

## 08. Проблемы и решения

### Проблема 1: Недостаточно ttyUSB устройств

**Симптомы**:
```
[ERROR] Cannot create /dev/ttyUSB254: Device or resource busy
```

**Решение**: Применить патч serial.h для увеличения SERIAL_TTY_MINORS до 1022.

### Проблема 2: Модуль не загружается

**Симптомы**:
```
FATAL: Error inserting option: Invalid module format
```

**Решение**: Перекомпилировать модуль option.c с правильными флагами ядра.

### Проблема 3: Устройства не определяются

**Симптомы**:
```
lsusb показывает устройство, но /dev/ttyUSB* не создаётся
```

**Решение**: Добавить Vendor/Product ID в таблицу option.c:
```c
static const struct usb_device_id option_ids[] = {
    { USB_DEVICE(HUAWEI_VENDOR_ID, HUAWEI_PRODUCT_E173) },
    // ...
};
```

---

## 09. Безопасность

### Риски

1. **Модификация ядра** — может привести к нестабильности системы
2. **Отключение отладки** — затрудняет диагностику проблем
3. **Увеличение памяти** — больше портов = больше потребление памяти

### Рекомендации

1. Тестировать на не-production системе
2. Делать backup оригинальных файлов
3. Иметь возможность отката (GRUB с старым ядром)

---

## 10. TODO

- [ ] Автоматизация применения патчей
- [ ] Тестирование на новых версиях ядра
- [ ] Добавление поддержки новых устройств
- [ ] Документирование процесса сборки

---

## 11. Связанные документы

| Документ | Связь |
|----------|-------|
| [SDD: Dongle Control](../sdd-dongle-control/) | USB модемы |
| [SDD: chan_dongle](../sdd-chan-dongle/) | Asterisk модуль |
| [ADR-001](../adr-001-file-based-state/) | Файловое хранилище |

---

*Generated by /legacy analysis — 2026-03-03*
