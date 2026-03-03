# SDD: AI & Automation

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Spec-Driven Development  
**Module**: AI & Automation

---

## 01. Requirements

### Overview

The AI & Automation module provides intelligent automation for SIM-box operations including voice recognition, automated call handling, SMS automation, watchdog monitoring, and automatic SIM blocking based on statistics.

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | Voice recognition for call recordings (Yandex SpeechKit) | HIGH |
| FR-02 | Automated PIN entry for carriers (Tele2) | HIGH |
| FR-03 | Automatic call initiation for test calls (samsebe) | HIGH |
| FR-04 | SMS automation (balance requests, spam) | HIGH |
| FR-05 | Watchdog monitoring for Asterisk | HIGH |
| FR-06 | Automatic SIM blocking based on DATT/ACDL | HIGH |
| FR-07 | Carrier-specific autopilot rules | MEDIUM |
| FR-08 | Voice recognition parsing and categorization | MEDIUM |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Low-priority process execution (nice, ionice) |
| NFR-02 | Integration with central server for recognition results |
| NFR-03 | File-based state coordination |
| NFR-04 | Russian language recognition |

### Constraints

- Yandex SpeechKit API key hardcoded
- Requires sox for audio processing
- Central server (simserver:8122) for recognition storage

---

## 02. Specifications

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  AI & Automation Module                  │
│                      ai/                                 │
│  ┌─────────────┬─────────────┬─────────────┬──────────┐│
│  │ recog/      │ autopilot/  │ sms/        │ block/   ││
│  │ Voice       │ Automated   │ SMS         │ Auto-    ││
│  │ Recognition │ Actions     │ Automation  │ blocking ││
│  ├─────────────┼─────────────┼─────────────┼──────────┤│
│  │ samsebe/    │ watchdog/   │ automag/    │ ai.sh    ││
│  │ Self-calls  │ Monitoring  │ Magic auto  │ Orchestr ││
│  └─────────────┴─────────────┴─────────────┴──────────┘│
└─────────────────────────────────────────────────────────┘
```

### Module Structure

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `recog/` | Voice recognition | dorecog.php, parse/ |
| `autopilot/` | Automated actions | autopilot.php, tele2/ |
| `sms/` | SMS automation | autosms.php, find_need_sms.sh |
| `block/` | Auto-blocking | block.sh, find_high_datt.sh |
| `samsebe/` | Self-test calls | makecall_need_in.sh |
| `watchdog/` | System monitoring | watchdog.sh, dog_peers.sh |
| `automag/` | Magic automation | (auto-magic rules) |

### Voice Recognition Flow (recog/)

```
Call Recording
      │
      ▼
┌─────────────────┐
│ sox processing  │
│ - Convert to    │
│   16kHz PCM     │
│ - Trim to 7s    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Yandex SpeechKit│
│ POST /asr_xml   │
│ - 16kHz PCM     │
│ - Russian lang  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Parse XML       │
│ - Extract       │
│   variants      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Save to Server  │
│ recog_save.php  │
│ - Pre-answer    │
│ - Post-answer   │
│ - In/Out        │
└─────────────────┘
```

### dorecog.php - Recognition Script

```php
#!/usr/bin/php
<?php
$uid = $argv[1];        // Unique call ID
$dialstatus = $argv[2]; // Call status
$imsi = $argv[3];       // SIM IMSI
$numberb = $argv[4];    // Destination number
$billsec = $argv[5];    // Call duration

// Process 4 audio tracks
$pre_in  = rasp3($uid."-pre-in",  $uid, 1, $billsec);
$pre_out = rasp3($uid."-pre-out", $uid, 1, $billsec);
$ans_in  = rasp3($uid."-ans-in",  $uid, 1, $billsec);
$ans_out = rasp3($uid."-ans-out", $uid, 1, $billsec);

// Send to central server
$url = 'http://simserver:8122/recog/recog_save.php?'
     . 'uid='.$uid
     . '&pre_in='.urlencode($pre_in)
     . '&pre_out='.urlencode($pre_out)
     . '&ans_in='.urlencode($ans_in)
     . '&ans_out='.urlencode($ans_out)
     . '&billsec='.$billsec
     . '&numberb='.urlencode($numberb)
     . '&dialstatus='.urlencode($dialstatus);

$result = file_get_contents($url);
list($status, $recog_type) = explode(";", $result);

// Log results
if ($status == "OK") {
    file_put_contents("/var/svistok/sim/log/$imsi.rasp_imsi",
        "$uid;$status;$recog_type;...$pre_in;...$pre_out;...$ans_in;...$ans_out\n",
        FILE_APPEND);
}

function rasp3($filename, $uid, $pre, $billsec) {
    // Convert audio with sox
    exec('sox -V3 /var/spool/asterisk/monitor/'.$filename.'.wav '
        .'-r 16000 -b 16 -c 1 /tmp/'.$filename.'-pcm.wav '
        .'trim 0 0:07 2>&1', $out);
    
    // Send to Yandex
    $result = yandexspeech("/tmp/$filename-pcm.wav");
    unlink("/tmp/$filename-pcm.wav");
    
    return "[y]".$result;
}

function yandexspeech($filename) {
    $key = '57eda14d-e0e2-4cdc-938c-b99844a07fd8'; // Hardcoded API key
    $topic = "freeform";
    $lang = "ru-RU";
    
    exec('curl --silent '
        .'-F "Content-Type=audio/x-pcm;bit=16;rate=16000" '
        .'-F "audio=@'.$filename.'" '
        .'asr.yandex.net/asr_xml?key='.$key
        .'&uuid='.rand()
        .'&topic='.$topic
        .'&lang='.$lang, $xml);
    
    $res_xml = implode($xml);
    
    // Parse XML response
    $p = xml_parser_create();
    xml_parse_into_struct($p, $res_xml, $vals, $index);
    
    $r = "";
    foreach ($vals as $k => $v) {
        if ($v['tag'] == "VARIANT") {
            $r .= $v['value'] . "/";
        }
    }
    return $r;
}
?>
```

### Autopilot (autopilot/)

```php
#!/usr/bin/php
<?php
// Automated actions based on SIM state

function can_autopilot($autopilot, $iccid, $once, $pause_next_sim, $pause_next_action) {
    $last_action = file_get_contents("/var/svistok/sim/statistics/$autopilot.last_action");
    
    if (time() - $last_action < $pause_next_action) {
        return FALSE;  // Too soon
    }
    
    file_put_contents("/var/svistok/sim/statistics/$autopilot.last_action", time());
    return TRUE;
}

// Read dongle list
$dongles = fopen("/var/svistok/lists/dongles.list", "r");
while (!feof($dongles)) {
    $dongle = trim(fgets($dongles, 4096));
    $imsi = @file_get_contents("/var/svistok/dongles/state/$dongle.imsi");
    $iccid = @file_get_contents("/var/svistok/dongles/state/$dongle.iccid");
    $spn = substr($iccid, 3, 4);
    
    if (substr($iccid, 3, 4) == "0721") $spn = "TELE2";
    $state = @file_get_contents("/var/svistok/dongles/state/$dongle.str_state");
    
    // Auto PIN entry for Tele2
    if ((strstr($state, "PIN")) && ($spn == "TELE2")) {
        if (can_autopilot("tele2_enter_pin", $iccid, TRUE, 456, 456)) {
            system("/usr/simbox/nabor/tele2_spb/commands/enter_pin.sh $dongle");
        }
    }
}
fclose($dongles);
?>
```

### SMS Automation (sms/)

```php
#!/usr/bin/php
<?php
// autosms.php - Continuous SMS automation loop

while (1) {
    $imsilist = file("/var/svistok/lists/imsi.list");
    
    foreach ($imsilist as $k => $imsi) {
        $imsi = trim($imsi);
        $group = file_get_contents("/var/svistok/sim/settings/".$imsi.".group");
        $busy = @file_get_contents("/var/svistok/sim/state/".$imsi.".busy");
        $str_state = file_get_contents("/var/svistok/sim/state/".$imsi.".str_state");
        
        if (($busy != 1) && ($str_state == "Free")) {
            // Send SMS for specific groups
            if (in_array($group, [285, 284, 212, 211, 210, 209, 208, 220])) {
                system('/usr/simbox/ai/sms/sendsms_imsi.php "'.$imsi.'"');
                usleep(500000);
            }
        }
    }
    sleep(10);
}
?>
```

### Auto-Blocking (block/)

```bash
#!/bin/sh
# block.sh - Automatic SIM blocking based on statistics

. /usr/simbox/config.sh

maxdatt=10
maxdatt1=8
maxdatt2=20

imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do
    high_datt=`cat $PATH_SIMBOX_SIM_STATE/$imsi.high_datt`
    low_acdl=`cat $PATH_SIMBOX_SIM_STATE/$imsi.low_acdl`
    group=`cat $PATH_SVISTOK_SIM_SETTINGS/$imsi.group`
    
    if [ $group -gt "99" ] && [ "290" -gt $group ]; then
        # Block on high DATT
        if [ $high_datt -gt "0" ] && [ $group -ne "222" ]; then
            $ASTERISK -r -x "dongle setgroupimsi $imsi 333"
            date +"%Y-%m-%d %H:%M:%S" > $PATH_SIMBOX_SIM_STATE/$imsi.date_blocked
        fi
        
        # Block on low ACDL
        if [ $low_acdl -gt "0" ]; then
            $ASTERISK -r -x "dongle setgroupimsi $imsi 334"
            date +"%Y-%m-%d %H:%M:%S" > $PATH_SIMBOX_SIM_STATE/$imsi.date_blocked
        fi
    fi
done
```

### find_high_datt.sh

```bash
#!/bin/sh
# Detect high DATT (call answer rate)

. /usr/simbox/config.sh

maxdatt1=14  # Threshold

imsilist=`cat $FILE_IMSILIST`

for imsi in $imsilist
do
    datt=`cat $PATH_SVISTOK_SIM_STATISTICS/$imsi.stat_datt`
    
    if [ "$datt" -gt "$maxdatt1" ]; then
        echo "$imsi high_datt"
        echo 1 > $PATH_SIMBOX_SIM_STATE/$imsi.high_datt
    fi
done
```

### Samsebe (Self-Test Calls)

```php
#!/usr/bin/php
<?php
// makecall_need_in.sh - Automated test calls

$imsilist = file("/var/svistok/lists/imsi.list");

foreach ($imsilist as $k => $imsi) {
    $imsi = trim($imsi);
    $group = file_get_contents("/var/svistok/sim/settings/$imsi.group");
    $need_in = file_get_contents("/var/simbox/sim/state/$imsi.need_in");
    $number = file_get_contents("/var/simbox/sim/settings/$imsi.number");
    $busy = file_get_contents("/var/svistok/sim/state/$imsi.busy");
    $str_state = file_get_contents("/var/svistok/sim/state/$imsi.str_state");
    $ca = file_get_contents("/var/svistok/sim/statistics/$imsi.stat_in_answered");
    
    // Group 102: Make up to 5 test calls
    if ($group == 102 && $ca <= 5) {
        $need_in = 1;
    }
    
    // Groups 100-199: Make test calls if needed
    if (($group > 99) && ($group < 200)) {
        if ($need_in == 1 && $busy != 1 && $number > 0 && $str_state == "Free") {
            $cmd = "/usr/simbox/system/makecallsebe.sh \"nodongle\" \"$number\" \"$imsi\"";
            system($cmd);
            sleep(10);
        }
    }
}
?>
```

### Watchdog (System Monitoring)

```bash
#!/bin/bash
# watchdog.sh - Monitor Asterisk and auto-reboot if down

sudo /usr/simbox/ai/watchdog/dog_peers.sh &
sleep 4

result=`cat /tmp/dog_peers.lock`

if [ "$result" == "99" ]; then
    echo "ASTERISK OK"
fi

if [ "$result" == "100" ]; then
    echo "ASTERISK DOWN $result"
    sudo reboot
fi
```

### Main Orchestrator (ai.sh)

```bash
#!/bin/sh
# ai.sh - Main AI automation orchestrator

# Low priority execution
renice 19 -p $$
ionice -c3 -p $$

# Blocking detection
/usr/simbox/ai/block/find_high_datt.sh
/usr/simbox/ai/block/find_low_acdl.sh
/usr/simbox/ai/block/block.sh

# Self-test calls
/usr/simbox/ai/samsebe/find_in_done.sh
/usr/simbox/ai/samsebe/find_need_in.sh

# SMS automation
/usr/simbox/ai/sms/find_sms_done.sh
/usr/simbox/ai/sms/find_need_sms.sh

# Make test calls (background, staggered)
/usr/simbox/ai/samsebe/makecall_need_in.sh &
sleep 20
/usr/simbox/ai/samsebe/makecall_need_in.sh &
sleep 20
/usr/simbox/ai/samsebe/makecall_need_in.sh &
sleep 20
/usr/simbox/ai/samsebe/makecall_need_in.sh &
```

---

## 03. Integration Points

### Central Server API

| Endpoint | Purpose |
|----------|---------|
| `/recog/recog_save.php` | Store voice recognition results |

### External Services

| Service | Purpose | Notes |
|---------|---------|-------|
| Yandex SpeechKit | Voice-to-text | API key hardcoded |
| Asterisk AMI | Call control | Via CLI commands |

### File-Based State

| File | Purpose |
|------|---------|
| `$imsi.high_datt` | High DATT flag |
| `$imsi.low_acdl` | Low ACDL flag |
| `$imsi.date_blocked` | Block timestamp |
| `$autopilot.last_action` | Rate limiting |

---

## 04. Security Considerations

- **Yandex API Key**: Hardcoded in dorecog.php (`57eda14d-e0e2-4cdc-938c-b99844a07fd8`)
- **HTTP Transmission**: Recognition data sent over unencrypted HTTP
- **Auto-Reboot**: Watchdog can trigger system reboot
- **Privilege Escalation**: Scripts run via sudo

---

## 05. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [ADR-005](../adr-005-central-ki/): Central KI Management
- [SDD: Call Engine](../sdd-call-engine/): Call routing
- [VDD: Web Interface](../vdd-web-interface/): Debug page

---

*Generated by /legacy analysis - 2026-03-03*
