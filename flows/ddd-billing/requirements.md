# DDD: Billing System

**Date**: 2026-03-03  
**Status**: DRAFT  
**Type**: Document-Driven Development  
**Module**: Billing

---

## 01. Requirements

### Overview

The Billing system provides stakeholder-facing documentation and tracking for call costs, revenue, and carrier expenses across multiple regions and operators.

### Stakeholder Requirements

| ID | Requirement | Stakeholder |
|----|-------------|-------------|
| SR-01 | Daily call cost reports | Management |
| SR-02 | Per-carrier expense tracking | Finance |
| SR-03 | Per-region cost analysis | Operations |
| SR-04 | Balance prediction alerts | Operations |
| SR-05 | Mass payment export | Finance |

### Business Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| BR-01 | Track call minutes per direction | HIGH |
| BR-02 | Calculate costs based on carrier rates | HIGH |
| BR-03 | Export payment data for external systems | HIGH |
| BR-04 | Support multiple currencies | MEDIUM |
| BR-05 | Generate invoices | LOW |

### Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-01 | Russian language reports |
| NFR-02 | Daily aggregation |
| NFR-03 | File-based storage (compatible with existing system) |
| NFR-04 | Export to standard formats |

---

## 02. Specifications

### Data Model

```
/var/svistok/sim/statistics/billing/
├── 01.03.2026.bee_spb    # Beeline SPb calls
├── 01.03.2026.meg_msk    # MegaFon Moscow calls
├── 01.03.2026.mts_spb    # MTS SPb calls
├── 01.03.2026.tele2_spb  # Tele2 SPb calls
├── 01.03.2026.kievstar   # Kievstar calls
├── 01.03.2026.velcom_by  # Velcom Belarus calls
├── 01.03.2026.life_by    # Life Belarus calls
└── 01.03.2026.system     # Internal/system calls
```

### Carrier Rate Card

| Direction | Code | Rate (USD/min) |
|-----------|------|----------------|
| Beeline Moscow | BM | 0.020 |
| Beeline SPb | BS | 0.020 |
| Beeline Russia | BR | 0.020 |
| MegaFon Moscow | NM | 0.015 |
| MegaFon SPb | NS | 0.015 |
| MegaFon Russia | NR | 0.015 |
| MTS Moscow | SM | 0.020 |
| MTS SPb | SS | 0.020 |
| MTS Russia | SR | 0.020 |
| MTS Belarus | SB | 0.100 |
| Tele2 SPb | TS | 0.020 |
| Kievstar | KU | 0.050 |
| Velcom Belarus | VB | 0.100 |
| Life Belarus | LB | 0.100 |

### Billing Page (bablo.php)

```php
<?php
$total_minutes = 0;
$total_cost = 0;

$files = scandir("/var/svistok/sim/statistics/billing");

foreach ($files as $file) {
    if ($file == '.' || $file == '..') continue;
    
    $parts = explode('.', $file);
    $date = $parts[0];
    $direction = $parts[1];
    
    $minutes = minsec(file_get_contents_def2(
        "/var/svistok/sim/statistics/billing/".$file, "0"
    ));
    
    $rate = get_rate($direction);  // Rate from card above
    $cost = round($minutes * $rate, 2);
    
    $total_minutes += $minutes;
    $total_cost += $cost;
    
    echo "<tr>";
    echo "<td>$date</td>";
    echo "<td>".html_napr($direction)."</td>";
    echo "<td>$minutes</td>";
    echo "<td>$cost</td>";
    echo "</tr>";
}

echo "<tr class='header'>";
echo "<td>Total</td>";
echo "<td></td>";
echo "<td>$total_minutes</td>";
echo "<td>$total_cost</td>";
echo "</tr>";
?>
```

### Mass Payment Export

```php
<?php
// Export for mass payment processing
if (isset($_POST['export_masspayment'])) {
    $need_balance = $_POST['export_masspayment_balance'];
    $min_payment = $_POST['export_masspayment_balance_minimum'];
    $max_payment = $_POST['export_masspayment_balance_maximum'];
    
    foreach ($_POST['id'] as $v => $imsi) {
        $plan = file_get_contents_def2($path_simbox_sim_settings.$imsi.'.plan', 'default');
        $number = file_get_contents_def2($path_simbox_sim_settings.$imsi.'.number', '');
        $nabor = file_get_contents_def($path_simbox_plan.$plan.'.nabor', 'default');
        $balance = file_get_contents_def2($path_simbox_sim_statistics.$imsi.'.balance', '0');
        
        // Calculate payment amount based on carrier
        $op_id = get_operator_id($nabor);
        $to_pay = calculate_payment($need_balance, $balance, $nabor);
        
        // Format for payment system
        echo "$number;$op_id;$to_pay;WMR;$cnt<br>";
    }
}

function get_operator_id($nabor) {
    $operators = [
        'beeline_spb' => 2,
        'tele2_spb' => 31,
        'megafon_spb' => 10,
        'megafon_msk' => 3,
        'life' => 623,
        'velcom' => 621,
    ];
    return $operators[$nabor] ?? 0;
}

function calculate_payment($need, $balance, $nabor) {
    // Belarus operators use different currency
    if (in_array($nabor, ['life', 'velcom'])) {
        $balance = $balance / 252;  // Convert to USD
    }
    $to_pay = $need - $balance;
    return max(0, (int)($to_pay + 0.99));
}
?>
```

### Reports

#### Daily Summary Report

```
Биллинг - Daily Summary
═══════════════════════════════════════════════════════════
Date: 01.03.2026

Direction          Minutes    Cost (USD)
─────────────────────────────────────────
[🟦] Beeline SPb     125.50      2.51
[🟩] MegaFon Msk      85.20      1.28
[🟥] MTS SPb          45.00      0.90
[🟪] Tele2 SPb        67.30      1.35
[🟨] Kievstar         23.10      1.16
[🟧] Velcom BY        12.50      1.25
[🔵] Life BY           8.40      0.84
─────────────────────────────────────────
TOTAL               367.00      9.29
═══════════════════════════════════════════════════════════
```

#### Balance Alert Report

```
Balance Alert - Low Balance SIMs
═══════════════════════════════════════════════════════════
Generated: 01.03.2026 09:00

IMSI            Number        Balance    Carrier
─────────────────────────────────────────────────
250201234567890 +79991234567  15.50 RUB  MegaFon
250201234567891 +78121234567  8.20 RUB   Beeline
250201234567892 +380671234567 5.00 UAH   Kievstar
─────────────────────────────────────────────────
Action Required: Top-up recommended
═══════════════════════════════════════════════════════════
```

---

## 03. Stakeholder Communication

### For Management

**Key Metrics**:
- Total daily call minutes
- Total daily cost
- Cost per minute average
- Top 5 routes by volume

### For Finance

**Payment Processing**:
- Mass payment export format
- Operator IDs for each carrier
- Minimum/maximum payment thresholds
- Currency conversion rates (BYR, UAH, RUB)

### For Operations

**Monitoring**:
- Low balance alerts
- Blocked SIM notifications
- Carrier performance metrics
- Route quality indicators

---

## 04. Related Documents

- [ADR-001](../adr-001-file-based-state/): File-Based State Storage
- [ADR-002](../adr-002-imsi-centric-model/): IMSI-Centric Data Model
- [ADR-004](../adr-004-zone-routing/): Zone-Based Call Routing
- [SDD: Call Engine](../sdd-call-engine/): Call routing
- [VDD: Web Interface](../vdd-web-interface/): Billing UI

---

*Generated by /legacy analysis - 2026-03-03*
