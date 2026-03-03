# VDD: Web Interface - Specifications

**Date**: 2026-03-03  
**Status**: DRAFT

---

## Technical Specifications

### head.php - Core Utilities

```php
<?php
// File read with default
function file_get_contents_def($filename, $def) {
    $res = @file_get_contents($filename);
    if ($res == "") {
        file_put_contents($filename, $def);
        $res = $def;
    }
    return $res;
}

// Execute with sudo
function exec_s($cmd) {
    $return = system("sudo " . $cmd);
}

// Execute in background
function exec_fon($cmd) {
    system("sudo " . $cmd . " >/dev/null & >/dev/null");
}

// Execute with random delay (anti-detection)
function exec_delay($cmd) {
    if (@$_POST['delay_rnd'] > 0) {
        $rnd = (rand() % @$_POST['delay_rnd']) + @$_POST['delay_min'];
        $cmd = "( /bin/sleep $rnd && sudo $cmd ) >>/tmp/exec.log 2>>/tmp/exec.err &";
        exec_br($cmd);
    } else {
        $cmd = "sudo $cmd";
        exec_br($cmd);
    }
}
?>
```

### html.php - UI Helpers

```php
<?php
// Dongle model icon
function html_dongle($model) {
    $dongle_img = '<img src="imgs/dongle.png">'.$model;
    if ($model == "E1550") $dongle_img = '<img src="imgs/dongle1550.ico">';
    if ($model == "E173") $dongle_img = '<img src="imgs/dongle173.ico">';
    return $dongle_img;
}

// Power state icon
function html_cfun($cfun) {
    if ($cfun == "-1") return '<img src="imgs/state/-1.ico">';
    if ($cfun == "1") return '<img src="imgs/p-on.png">';
    if ($cfun == "5") return '<img src="imgs/p-off.png">';
    return $cfun;
}

// Signal strength icon
function html_rssi($rssi) {
    if ($rssi == "" || $rssi == "-1") return "";
    if ($rssi == 0) return '<img src="imgs/rssi/rssi-0.ico">';
    if ($rssi > 0 && $rssi < 7) return '<img src="imgs/rssi/rssi-1.ico">';
    if ($rssi >= 7 && $rssi < 15) return '<img src="imgs/rssi/rssi-2.ico">';
    if ($rssi >= 15 && $rssi < 20) return '<img src="imgs/rssi/rssi-3.ico">';
    if ($rssi >= 20 && $rssi < 31) return '<img src="imgs/rssi/rssi-4.ico">';
    if ($rssi == 31) return '<img src="imgs/rssi/rssi-4.ico">';
}

// Group status icon
function html_group($group, $pause) {
    if ($group >= 100 && $group <= 299) {
        $img = '<img src="imgs/play.png">';
        if ($pause == 1) $img = '<img src="imgs/pause.png"><img src="imgs/day_work.png">';
        if ($pause == 2) $img = '<img src="imgs/pause.png"><img src="imgs/day_holiday.png">';
    }
    if ($group == 333) $img = '<img src="imgs/high_datt.ico">';
    if ($group >= 300 && $group <= 399) $img = '<img src="imgs/low_acdl.png">';
    if ($group >= 400 && $group <= 499) $img = '<img src="imgs/low_balance.png">';
    if ($group >= 500 && $group <= 599) $img = '<img src="imgs/blocked.png">';
    return $img;
}

// Carrier direction icon
function html_napr($billing_direction) {
    $icons = [
        'bee_msk' => 'imgs/napravleine/beeline_msk.ico',
        'bee_spb' => 'imgs/napravleine/beeline_spb.ico',
        'meg_msk' => 'imgs/napravleine/megafon_msk.ico',
        'meg_spb' => 'imgs/napravleine/megafon_spb.ico',
        'mts_spb' => 'imgs/napravleine/mts_spb.ico',
        'tele2_spb' => 'imgs/napravleine/tele2_spb.ico',
        'kievstar' => 'imgs/napravleine/kievstar.ico',
        'velcom_by' => 'imgs/napravleine/velcom_by.ico',
        'life_by' => 'imgs/napravleine/life_by.ico',
    ];
    return isset($icons[$billing_direction]) 
        ? '<img src="'.$icons[$billing_direction].'">' 
        : $billing_direction;
}
?>
```

### sim.php - SIM Management Actions

```php
<?php
// KI Programming (Type 9)
if (isset($_POST['setki'])) {
    foreach ($_POST['id'] as $v => $imsi) {
        $dongle = file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
        $cmd = '/usr/simbox/system/set_ki.php "9" "'.$dongle.'" "'.$ki.'" "'.$imsi.'" "'.$iccid.'" "'.$smsc.'"';
        exec_delay($cmd);
    }
}

// Auto KI (Type 9)
if (isset($_POST['newki'])) {
    foreach ($_POST['id'] as $v => $imsi) {
        $dongle = file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
        $cmd = '/usr/simbox/system/new_ki.php "9" "'.$dongle.'" "'.$_POST['ki_owner'].'"';
        exec_delay($cmd);
    }
}

// KI Rotation
if (isset($_POST['rotki'])) {
    foreach ($_POST['id'] as $v => $imsi) {
        $dongle = file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
        $cmd = '/usr/simbox/system/rot_ki.php "'.$dongle.'" "'.$_POST['rot_owner'].'" "'.$_POST['rot_ki'].'"';
        exec_delay($cmd);
    }
}

// Send USSD
if (isset($_POST['sendussd'])) {
    foreach ($_POST['id'] as $v => $imsi) {
        $dongle = file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
        $ussd = $_POST['ussdcommand'];
        $cmd = '/usr/simbox/system/send.sh "ussd" "LOC" "'.$dongle.'" "'.$ussd.'" ""';
        exec_delay($cmd);
    }
}

// Send SMS
if (isset($_POST['sendsms'])) {
    foreach ($_POST['id'] as $v => $imsi) {
        $dongle = file_get_contents($path_svistok_sim_state.$imsi.'.dongle');
        $smsnumber = $_POST['smsnumber'];
        $smstext = $_POST['smstext'];
        $cmd = '/usr/simbox/system/send.sh "sms" "LOC" "'.$dongle.'" "'.$smsnumber.'" "'.$smstext.'"';
        exec_delay($cmd);
    }
}
?>
```

### dongle.php - Dongle Management Actions

```php
<?php
// Change IMEI
if (isset($_POST['changeimei'])) {
    foreach ($_POST['id'] as $v => $dongle) {
        $cmd = '/usr/simbox/actions/changeimei.php '.$dongle.' noimsi';
        exec_delay($cmd);
    }
}

// Blacklist IMEI
if (isset($_POST['blackimei'])) {
    foreach ($_POST['id'] as $v => $dongle) {
        $imei = trim(file_get_contents($path_svistok_dongles_state.$dongle.'.imei'));
        file_put_contents($path_svistok_dongles.'imei.black', $imei."\n", FILE_APPEND);
    }
}

// Restart dongle
if (isset($_POST['donglerestart'])) {
    foreach ($_POST['id'] as $v => $dongle) {
        $cmd = '/usr/simbox/actions/donglerestart.sh '.$dongle.' noimsi';
        exec_delay($cmd);
    }
}

// Power control
if (isset($_POST['pon'])) {
    $_POST['atcommandexec'] = 1;
    $_POST['atcommand'] = 'AT+CFUN=1;+CFUN=1,1;+CFUN?';
}
if (isset($_POST['poff'])) {
    $_POST['atcommandexec'] = 1;
    $_POST['atcommand'] = 'AT+CFUN=5;+CFUN?';
}

// AT Command execution
if (isset($_POST['atcommandexec'])) {
    foreach ($_POST['id'] as $v => $dongle) {
        $atcommand = $_POST['atcommand'];
        $atcommand = str_replace('"', '\"', $atcommand);
        exec_delay("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
}

// Mode selection (GSM/WCDMA)
if (isset($_POST['setmode_gsm'])) {
    foreach ($_POST['id'] as $v => $dongle) {
        $atcommand = 'AT^SYSCFG=13,1,3FFFFFFF,0,3;+CFUN=1,1';
        exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
}
if (isset($_POST['setmode_wcdma'])) {
    foreach ($_POST['id'] as $v => $dongle) {
        $atcommand = 'AT^SYSCFG=14,2,3FFFFFFF,0,3;+CFUN=1,1';
        exec_s("/usr/sbin/asterisk -rx 'dongle cmd $dongle $atcommand'");
    }
}
?>
```

---

## File Index

| File | Purpose | Lines |
|------|---------|-------|
| www/simbox/index.php | Router | ~5 |
| www/simbox/head.php | Header, utilities | ~200 |
| www/simbox/foot.php | Footer | ~20 |
| www/simbox/sim.php | SIM management | ~2200 |
| www/simbox/dongle.php | Dongle management | ~800 |
| www/simbox/nabor.php | Command sets | ~400 |
| www/simbox/plan.php | Call plans | ~300 |
| www/simbox/bablo.php | Billing | ~150 |
| www/simbox/modules/html.php | UI helpers | ~350 |
| www/simbox/modules/actions.php | Action handlers | ~200 |
| www/simbox/modules/sms_texts.php | SMS templates | ~100 |

---

*Generated by /legacy analysis - 2026-03-03*
