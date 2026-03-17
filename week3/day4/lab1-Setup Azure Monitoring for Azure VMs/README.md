# Lab 1: Setup Azure Monitoring for Azure VMs

## 📋 Overview

This lab demonstrates how to set up **Azure Monitoring** for Azure Virtual Machines. Azure Monitor provides comprehensive solutions for collecting, analyzing, and acting on telemetry data. This lab covers enabling VM Insights (Monitor), viewing performance metrics through Azure Monitor, configuring CPU utilization alerts, and setting up email notification actions when thresholds are exceeded.

---

## 🎯 Objectives

- Navigate Azure Monitoring features for VMs
- Enable VM Insights (Monitor) with OpenTelemetry and Log-based metrics
- View VM performance metrics via Azure Monitor
- Create alert rules based on CPU utilization
- Configure action groups with email notifications
- Verify alerts are triggered and notifications are received

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Azure Account** | Active subscription (IDDAB2G) |
| **Virtual Machine** | `vm-sakit` (Ubuntu 24.04, Standard D2s v3) |
| **Resource Group** | `rg-sakit` |
| **Region** | North Europe |

---

## 📝 Lab Steps

### Step 1: Explore VM Monitoring Features

Navigate to the VM overview page and locate the **Monitoring** section in the left sidebar. Azure VMs include built-in monitoring capabilities:

![VM Overview with Monitoring](Screenshots/Screenshot%202026-03-10%20070626.png)

**Available Monitoring Tools:**

| Tool | Description |
|---|---|
| **Insights (Monitor)** | Comprehensive performance and dependency monitoring |
| **Alerts** | Notifications when metrics exceed thresholds |
| **Metrics** | Real-time metric visualization and charting |
| **Diagnostic settings** | Configure telemetry export destinations |
| **Logs** | Query logs with Kusto Query Language (KQL) |
| **Workbooks** | Interactive, visual reports |

---

### Step 2: Enable VM Insights (Monitor)

Navigate to **Monitoring → Insights (now Monitor)** and click **Configure** to enable enhanced monitoring:

![VM Monitor Overview](Screenshots/Screenshot%202026-03-10%20070839.png)

The Monitor dashboard displays:
- **VM availability:** ✅ Available
- **Azure outages:** ✅ No outages
- **Health events:** ⚠️ Events tracked
- **Network Troubleshooter:** Available for diagnostic tests

#### Configure Infrastructure Monitoring:

![Configure Monitor](Screenshots/Screenshot%202026-03-10%20070857.png)

Enable both monitoring options:

| Option | Status | Workspace |
|---|---|---|
| **OpenTelemetry metrics** (Preview) | ✅ Enabled | `defaultazuremonitorworkspace-par` |
| **Classic Log-based metrics** | ✅ Enabled | `defaultworkspace-5a775aa2-...` |

Click **Review + enable** to finalize the configuration.

#### Verify Onboarding:

![Monitor Onboarding Success](Screenshots/Screenshot%202026-03-10%20071412.png)

✅ **Result:** "Onboarding successful — Your environment is now onboarded." The deployment succeeded and monitoring is now active.

---

### Step 3: View Performance Metrics via Azure Monitor

Navigate to **Azure Monitor → Insights → Virtual Machines → Performance** to view metrics:

![Azure Monitor Performance](Screenshots/Screenshot%202026-03-10%20084941.png)

The Performance tab displays:

| Metric | Granularity | Value |
|---|---|---|
| **CPU Utilization %** | 1 minute | 0.75% (95th percentile) |

The chart shows CPU utilization over time, allowing you to identify performance trends and anomalies.

> **Azure Monitor** provides centralized monitoring across all Azure resources. The Insights view for VMs offers pre-built dashboards for CPU, memory, disk, and network metrics.

---

### Step 4: Create an Alert Rule

Navigate to **Azure Monitor → Alerts** and create a new alert rule:

![Create Alert Rule](Screenshots/Screenshot%202026-03-10%20085044.png)

#### Scope Configuration:

![Alert Scope](Screenshots/Screenshot%202026-03-10%20085219.png)

| Setting | Value |
|---|---|
| Scope level | Subscription |
| Resource | `vm-sakit` (IDDAB2G → rg-sakit) |

---

### Step 5: Configure Alert Condition

Select the signal and configure the alert logic:

![Select Signal](Screenshots/Screenshot%202026-03-10%20085247.png)

Select **Percentage CPU** from the popular signals list.

#### Alert Logic Configuration:

![Alert Logic](Screenshots/Screenshot%202026-03-10%20085554.png)

| Setting | Value |
|---|---|
| Signal name | Percentage CPU |
| Threshold type | Static |
| Aggregation type | Average |
| Operator | Greater than |
| Threshold | **80%** |
| Check every | 5 minutes |
| Lookback period | 5 minutes |

The preview panel shows: *"Whenever the average Percentage CPU is greater than 80%"* with an estimated cost of **$0.10 USD/month**.

---

### Step 6: Configure Actions (Quick Actions)

Set up a quick action group with email notification:

![Quick Actions](Screenshots/Screenshot%202026-03-10%20090037.png)

| Setting | Value |
|---|---|
| Action group name | `VM-Alerts-Group-Sakit` |
| Display name | `VMAlertSakit` |
| Email | ✅ Enabled |

> **Quick Actions (Preview)** allows you to configure actions directly within the alert rule creation wizard without navigating to a separate action group creation flow.

---

### Step 7: Finalize Alert Rule Details

Configure the alert rule metadata:

![Alert Details](Screenshots/Screenshot%202026-03-10%20090516.png)

| Setting | Value |
|---|---|
| Subscription | IDDAB2G |
| Resource group | `rg-sakit` |
| Severity | 3 - Informational |
| Alert rule name | `cpu-above-80` |
| Description | "An email will be sent if CPU usage exceeds 80 percent." |

Review the complete alert rule configuration:

![Review and Create](Screenshots/Screenshot%202026-03-10%20090723.png)

**Final Review Summary:**

| Section | Value |
|---|---|
| Metric alert rule | 1 Condition |
| Total pricing | 0.10 USD/month |
| Scope | IDDAB2G → rg-sakit → vm-sakit |
| Signal name | Percentage CPU |
| Operator | Greater than |
| Threshold value | 80 |
| Lookback period | 5 minutes |
| Check every | 5 minutes |

Click **Create** to finalize the alert rule.

---

### Step 8: Verify Alert Rule

Confirm the alert rule is active in the **Alert rules** list:

![Alert Rules List](Screenshots/Screenshot%202026-03-10%20091906.png)

| Name | Condition | Severity | Target | Signal Type | Status |
|---|---|---|---|---|---|
| `cpu-above-80` | Percentage CPU > 80 | 3 - Informational | vm-sakit | Metrics | ✅ Enabled |

The **Fired Alerts** view shows:

![Fired Alerts](Screenshots/Screenshot%202026-03-10%20091827.png)

- **Total alerts:** 3
- **Critical:** 0
- **Warning:** 1
- **Informational:** 2

✅ **Result:** The alert rule is successfully created, enabled, and actively monitoring the VM's CPU usage.

---

## 📊 Summary

| Task | Status |
|---|---|
| Explore VM Monitoring features | ✅ |
| Enable VM Insights with OpenTelemetry | ✅ |
| View CPU metrics in Azure Monitor | ✅ |
| Create alert rule (CPU > 80%) | ✅ |
| Configure quick actions with email | ✅ |
| Verify alert rule is active and firing | ✅ |

---

## 💡 Key Takeaways

1. **Azure Monitor** provides unified monitoring across all Azure resources with built-in insights, metrics, and alerting
2. **VM Insights** with OpenTelemetry enables detailed performance and dependency tracking at no additional cost
3. **Alert rules** proactively notify teams when metrics exceed defined thresholds, enabling faster incident response
4. **Action groups** centralize notification delivery — supporting email, SMS, push, voice, and automated actions
5. **Static vs Dynamic thresholds:** Static uses fixed values; Dynamic uses machine learning to detect anomalies
6. The **lookback period** and **check frequency** control how often Azure evaluates the alert condition
7. Azure Monitor integrates with **Grafana dashboards** for advanced visualization capabilities
