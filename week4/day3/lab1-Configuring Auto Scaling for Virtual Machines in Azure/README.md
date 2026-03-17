# Lab 1: Configuring Auto Scaling for Virtual Machines in Azure

## 📋 Overview

This lab demonstrates how to configure **Auto Scaling** for Azure Virtual Machines using **Virtual Machine Scale Sets (VMSS)**. Auto scaling automatically adjusts the number of VM instances based on demand metrics like CPU utilization. The lab covers creating a VMSS, configuring scale-out and scale-in rules, stress testing to trigger scaling, monitoring scaling events, and setting up alert rules with email notifications.

---

## 🎯 Objectives

- Create a Virtual Machine Scale Set (VMSS) in Azure
- Configure autoscale rules based on CPU metrics
- Perform stress testing to trigger scale-out events
- Monitor auto-scaling behavior and run history
- Create alert rules with action groups for email notifications
- Verify alert triggers via email

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Azure Account** | Active subscription (IDDAB2G) |
| **Azure Portal** | Access to the Azure Portal |
| **Resource Group** | `devops-vmss-lab-rg-sakit` |

---

## 📝 Lab Steps

### Step 1: Create a Virtual Machine Scale Set (VMSS)

Navigate to **Virtual Machine Scale Sets** in the Azure Portal and create a new VMSS:

![VMSS Creation](Screenshots/Screenshot%202026-03-11%20105606.png)

**VMSS Configuration:**

| Setting | Value |
|---|---|
| Name | `devops-vmss-lab-sakit` |
| Resource group | `devops-vmss-lab-rg-sakit` |
| Region | North Europe |
| Orchestration mode | Uniform |
| Image | Ubuntu Server 24.04 LTS |
| Instance count | 2 (initial) |
| VM Size | Standard_D2s_v3 |

![VMSS Configuration](Screenshots/Screenshot%202026-03-11%20110533.png)

> **What is VMSS?** A Virtual Machine Scale Set lets you create and manage a group of identical, load-balanced VMs. The number of VM instances can automatically increase or decrease in response to demand or a defined schedule.

---

### Step 2: Configure Autoscale Rules

Navigate to **Scaling** under the VMSS settings and configure autoscale rules:

![Scaling Configuration](Screenshots/Screenshot%202026-03-11%20110820.png)

#### Scale-Out Rule (Increase Instances):

| Setting | Value |
|---|---|
| Metric | Percentage CPU |
| Operator | Greater than |
| Threshold | **80%** |
| Duration | 5 minutes |
| Action | Increase count by **1** |
| Cool down | 5 minutes |

#### Scale-In Rule (Decrease Instances):

| Setting | Value |
|---|---|
| Metric | Percentage CPU |
| Operator | Less than |
| Threshold | **30%** |
| Duration | 5 minutes |
| Action | Decrease count by **1** |
| Cool down | 5 minutes |

![Autoscale Rules](Screenshots/Screenshot%202026-03-11%20110835.png)

**Instance Limits:**

| Setting | Value |
|---|---|
| Minimum | 2 |
| Maximum | 5 |
| Default | 2 |

> **Cool Down Period:** The cool down period prevents rapid scaling fluctuations by waiting a specified time before evaluating scaling rules again after a scaling action.

---

### Step 3: Stress Test to Trigger Scaling

SSH into one of the VMSS instances and install a stress testing tool:

```bash
# Install stress tool
sudo apt-get update && sudo apt-get install -y stress

# Run stress test (4 CPU workers for 300 seconds)
stress --cpu 4 --timeout 300
```

![Stress Testing](Screenshots/Screenshot%202026-03-11%20112132.png)

This generates high CPU load to exceed the 80% threshold and trigger the scale-out rule.

---

### Step 4: Monitor Scaling Events

After the stress test, check the **Instances** tab to see the new instances:

![Instances After Scale-Out](Screenshots/Screenshot%202026-03-11%20122124.png)

The VMSS scaled from **2 instances to 3 instances** in response to the high CPU utilization:

| Instance Name | Computer Name | Status |
|---|---|---|
| devops-vmss-lab-sakit_14d1b3e3 | devops-vm5RYFVN | ✅ Running |
| devops-vmss-lab-sakit_64a17a08 | devops-vmRX67T4 | ✅ Running |
| devops-vmss-lab-sakit_6dbdb1ed | devops-vmUG6771 | ✅ Running |

Check the **Run History** to see the scaling event details:

![Scaling Run History](Screenshots/Screenshot%202026-03-11%20122506.png)

The graph shows the instance count increasing from 2 to 3, and the event log confirms: **"Autoscale scale up completed"**.

---

### Step 5: Create Alert Rules

Navigate to **Alerts** under the VMSS Monitoring section and create a new alert rule:

![Create Alert](Screenshots/Screenshot%202026-03-11%20122641.png)

#### Alert Condition:

| Setting | Value |
|---|---|
| Signal | Percentage CPU |
| Threshold type | Static |
| Aggregation type | Average |
| Operator | Greater than |
| Threshold | **80%** |

![Alert Condition](Screenshots/Screenshot%202026-03-11%20122900.png)

---

### Step 6: Configure Action Group

Create an action group to define what happens when the alert fires:

![Action Group Creation](Screenshots/Screenshot%202026-03-11%20123051.png)

**Action Group Settings:**

| Setting | Value |
|---|---|
| Action group name | `ScaleALert-Sakit` |
| Display name | `alertupsakit` |
| Resource group | `devops-vmss-lab-rg-sakit` |
| Region | Global |

#### Notification Configuration:

| Setting | Value |
|---|---|
| Notification type | Email/SMS message/Push/Voice |
| Name | Email for Alert |
| Channel | Email ✅ |

![Notification Setup](Screenshots/Screenshot%202026-03-11%20123245.png)

---

### Step 7: Finalize Alert Rule Details

Configure the alert rule details:

![Alert Rule Details](Screenshots/Screenshot%202026-03-11%20123631.png)

| Setting | Value |
|---|---|
| Severity | 3 - Informational |
| Alert rule name | `cpu-level` |
| Subscription | IDDAB2G |
| Resource group | `devops-vmss-lab-rg-sakit` |

Review and create the alert rule:

![Review and Create](Screenshots/Screenshot%202026-03-11%20123719.png)

---

### Step 8: Verify Alert Trigger

After the stress test triggers the CPU threshold, verify the alert fires correctly:

![Alert Email Received](Screenshots/Screenshot%202026-03-11%20130554.png)

✅ **Result:** An email notification was received with the following details:

| Field | Value |
|---|---|
| Alert rule | `cpu-level` |
| Metric | Percentage CPU |
| Time Aggregation | Average |
| Period | Over the last 5 mins |
| Value | **86.0995%** |
| Operator | GreaterThan |
| Threshold | 80 |

The alert was triggered because the average CPU usage (**86.1%**) exceeded the **80%** threshold.

---

## 📊 Summary

| Task | Status |
|---|---|
| Create VMSS with 2 instances | ✅ |
| Configure scale-out rule (CPU > 80%) | ✅ |
| Configure scale-in rule (CPU < 30%) | ✅ |
| Stress test to trigger scaling | ✅ |
| Verify instances scaled from 2 → 3 | ✅ |
| Create CPU alert rule | ✅ |
| Configure email notification action group | ✅ |
| Receive alert email notification | ✅ |

---

## 💡 Key Takeaways

1. **VMSS Auto Scaling** automatically adjusts capacity based on demand, ensuring optimal performance and cost efficiency
2. **Scale-out and scale-in rules** should be configured with appropriate thresholds and cool down periods
3. **Stress testing** is essential to validate that scaling rules work as expected before going to production
4. **Azure Monitor Alerts** provide proactive notification when metrics exceed defined thresholds
5. **Action Groups** centralize notification management — they can send emails, SMS, or trigger automated actions
6. The **cool down period** prevents scaling oscillation (rapid scale-out/scale-in cycles)
7. Always set **instance limits** (min/max) to prevent runaway scaling and unexpected costs
