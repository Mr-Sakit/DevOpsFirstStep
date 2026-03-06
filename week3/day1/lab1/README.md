# Lab 1 — Provision a Windows Virtual Machine on Azure

In this lab, a Windows Server VM was provisioned on Microsoft Azure, connected via Remote Desktop (RDP), and IIS was installed to verify inbound HTTP connectivity.

---

## 📌 Part A — Create a Resource Group

1. Navigate to **Resource Groups** in the Azure Portal
2. Click **+ Create** → Create new resource group

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `rg-win-lab-sakit` |
| **Region** | (Europe) Austria East |

3. Click **Review + create** → **Create**

![Part A — Resource Groups page](Screenshot%202026-03-03%20084336.png)

![Part A — Create resource group](Screenshot%202026-03-03%20084525.png)

---

## 📌 Part B — Create a Windows VM

### Basics Tab

Navigate to **Virtual machines** → **+ Create** → **Azure virtual machine**

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `rg-win-lab-sakit` |
| **Virtual machine name** | `vm-win-lab-sakit` |
| **Region** | (Europe) Austria East |
| **Availability options** | No infrastructure redundancy required |
| **Security type** | Standard |
| **Image** | Windows Server 2025 Datacenter: Azure Edition – x64 Gen2 |
| **VM architecture** | x64 |
| **Size** | Standard_D2s_v3 (2 vcpus, 8 GiB memory) |
| **Username** | `mr-sakit` |
| **Password** | ●●●●●●●●●● |
| **Public inbound ports** | Allow selected ports |
| **Select inbound ports** | RDP (3389) |

![Part B — Virtual machines Create page](Screenshot%202026-03-03%20084713.png)

![Part B — Basics tab (Project & Instance details)](Screenshot%202026-03-03%20084858.png)

![Part B — Basics tab (Image, Size)](Screenshot%202026-03-03%20085620.png)

![Part B — Basics tab (Admin account, Inbound ports)](Screenshot%202026-03-03%20085633.png)

### Disks Tab

| Setting | Value |
|---------|-------|
| **OS disk size** | Image default (127 GiB) |
| **OS disk type** | Standard SSD (locally-redundant storage) |

![Part B — Disks tab](Screenshot%202026-03-03%20085748.png)

### Networking Tab

| Setting | Value |
|---------|-------|
| **Virtual network** | (New) vnet-austriaeast-1 (rg-win-lab-sakit) |
| **Subnet** | (New) snet-austriaeast-1 (172.25.0.0 – 172.25.0.255) |
| **Public IP** | (new) vm-win-lab-sakit-ip |
| **NIC network security group** | Basic |
| **Public inbound ports** | Allow selected ports |
| **Select inbound ports** | RDP (3389) |

![Part B — Networking tab](Screenshot%202026-03-03%20085845.png)

### Review + Create

Validation passed. Estimated monthly cost: **$11.65** (Networking).

| Summary | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | rg-win-lab-sakit |
| **VM name** | vm-win-lab-sakit |
| **Region** | Austria East |
| **Price** | 1 X Standard D2s v3 — 0.2530 USD/hr |

Click **Create** to begin deployment.

![Part B — Review + create (Validation passed)](Screenshot%202026-03-03%20090201.png)

### Deployment Complete

Deployment completed successfully. Click **Go to resource** to view the VM.

![Part B — Deployment complete](Screenshot%202026-03-03%20090446.png)

---

## 📌 Part C — Note the Public IP

On the VM Overview page, the Public IP address was noted for RDP connection.

| Property | Value |
|----------|-------|
| **Status** | Running |
| **Location** | Austria East |
| **Operating system** | Windows |
| **Size** | Standard D2s v3 (2 vcpus, 8 GiB memory) |
| **Public IP** | `68.210.98.126` |
| **Private IP** | `172.25.0.4` |
| **VNet/Subnet** | vnet-austriaeast-1/snet-austriaeast-1 |
| **Computer name** | vm-win-lab-saki |
| **VM generation** | V2 |
| **Architecture** | x64 |
| **Time created** | 3/3/2026, 5:02 AM UTC |

![Part C — VM Overview page](Screenshot%202026-03-03%20090553.png)

---

## 📌 Part D — Connect via Remote Desktop (RDP)

### Step 1 — Download RDP File

Navigate to **Connect** → **Connect** on the VM page. Download the RDP file.

| Property | Value |
|----------|-------|
| **Source machine OS** | Windows |
| **Source IP** | 62.212.236.131 |
| **VM IP address** | Public IP \| 68.210.98.126 |
| **VM port** | 3389 |
| **Username** | mr-sakit |

![Part D — Connect via RDP (Download RDP file)](Screenshot%202026-03-03%20091248.png)

### Step 2 — Accept Security Warnings

Open the downloaded `.rdp` file. Accept the security warning to connect.

![Part D — Remote Desktop Connection security warning](Screenshot%202026-03-03%20092008.png)

![Part D — Certificate verification warning](Screenshot%202026-03-03%20092047.png)

### Step 3 — Windows Desktop

Successfully connected to the Windows Server VM via RDP. Server Manager opened automatically.

![Part D — Windows Server desktop with Server Manager](Screenshot%202026-03-03%20092617.png)

---

## 📌 Part E — First-Run Setup

Inside the Windows VM, Settings and Windows Update were checked. Server Manager's **Add roles and features** was highlighted for the next step.

![Part E — Settings, Windows Update, and Server Manager](Screenshot%202026-03-03%20093113.png)

---

## 📌 Part F — Install IIS to Verify Networking

### Step 1 — Add Roles and Features Wizard

1. Open **Server Manager** → click **Add roles and features**
2. **Installation Type:** Role-based or feature-based installation
3. **Server Selection:** `vm-win-lab-saki` — 172.25.0.4 — Microsoft Windows Server 2025 Datacenter Azure Edition
4. **Server Roles:** Check **Web Server (IIS)**
5. **Confirmation:** Review features (IIS Management Console, Common HTTP Features, Static Content, etc.)
6. Click **Install**

![Part F — Installation Type](Screenshot%202026-03-03%20093226.png)

![Part F — Server Selection](Screenshot%202026-03-03%20093338.png)

![Part F — Server Roles (Web Server IIS)](Screenshot%202026-03-03%20093428.png)

![Part F — Confirm installation selections](Screenshot%202026-03-03%20093516.png)

### Step 2 — Allow HTTP (Port 80) in NSG

Navigate to **VM** → **Networking** → **Network settings** → **Create port rule** → **Inbound port rule**.

| Setting | Value |
|---------|-------|
| **Source** | Any |
| **Destination** | Any |
| **Destination port ranges** | 80 |
| **Protocol** | TCP |
| **Action** | Allow |
| **Priority** | 100 |
| **Name** | `allow-http` |

![Part F — Network settings (Add inbound port rule)](Screenshot%202026-03-03%20093806.png)

![Part F — Inbound security rule configuration](Screenshot%202026-03-03%20093926.png)

### Step 3 — Verify IIS

Open a browser and navigate to `http://68.210.98.126/`. The IIS default welcome page was displayed successfully — confirming HTTP inbound connectivity.

![Part F — IIS default page verified](Screenshot%202026-03-03%20094150.png)

---

## 📌 Part G — Clean Up

To avoid unnecessary charges:

1. **Stop (deallocate)** the VM: VM page → **Stop**
2. **Delete everything**: Resource groups → `rg-win-lab-sakit` → **Delete resource group** → confirm

---

## 🧠 Key Takeaways

| Topic | Details |
|-------|---------|
| **Resource Group** | Logical container for grouping Azure resources |
| **Windows VM Image** | Windows Server 2025 Datacenter: Azure Edition |
| **VM Size** | Standard_D2s_v3 (2 vCPUs, 8 GiB RAM) |
| **RDP Port** | 3389 — Remote Desktop Protocol |
| **IIS** | Internet Information Services — Windows web server |
| **NSG Rule** | Network Security Group rules control inbound/outbound traffic |
| **HTTP Port** | 80 — must be explicitly allowed in NSG for web access |
| **Cost Control** | Always stop/deallocate or delete VMs after lab use |
