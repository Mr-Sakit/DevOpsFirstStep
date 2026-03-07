# Lab 2 — Provision an Azure Load Balancer with Two Linux Web Servers

> A **Load Balancer** distributes incoming network traffic across multiple backend servers so that no single server becomes overwhelmed. Azure Load Balancer operates at **Layer 4 (Transport)** and supports Public (internet-facing) and Internal configurations.

In this lab, a **Public Azure Load Balancer** was created to distribute HTTP traffic between two Linux VMs running the Apache web server.

---

## 📌 Step 1 — Create Two Linux Virtual Machines

Both VMs were created in the **same Resource Group** and **same Virtual Network** to ensure they can communicate and be pooled by the Load Balancer.

### VM 1 — `devops-lab-vm1-sakit`

#### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `rg-vm-lab-sakit` (New) |
| **Virtual machine name** | `devops-lab-vm1-sakit` |
| **Region** | (Europe) Austria East |
| **Availability options** | No infrastructure redundancy required |
| **Security type** | Standard |
| **Image** | Ubuntu Server 24.04 LTS – x64 Gen2 |
| **Size** | Standard_D2s_v3 (2 vcpus, 8 GiB memory) |
| **Authentication type** | SSH public key |
| **Username** | `mr-sakit` |
| **SSH public key source** | Generate new key pair |
| **Key pair name** | `devops-lab-vm1-sakit_key` |
| **Public inbound ports** | Allow selected ports — SSH (22) |

![Step 1 — VM1 Basics tab (Project & Instance details)](Screenshots/Screenshot%202026-03-04%20110128.png)

![Step 1 — VM1 Basics tab (Admin account & Inbound ports)](Screenshots/Screenshot%202026-03-04%20110138.png)

#### Disks Tab

| Setting | Value |
|---------|-------|
| **OS disk size** | Image default (30 GiB) |
| **OS disk type** | Standard SSD (locally-redundant storage) |
| **Delete with VM** | ✅ |

![Step 1 — VM1 Disks tab](Screenshots/Screenshot%202026-03-04%20110219.png)

#### Networking Tab

| Setting | Value |
|---------|-------|
| **Virtual network** | (New) `devops-lab-vnet-sakit` (rg-vm-lab-sakit) |
| **Subnet** | (New) snet-austriaeast-1 (172.16.0.0/24) |
| **Public IP** | (new) `devops-lab-vm1-sakit-ip` |
| **NIC network security group** | Basic |
| **Public inbound ports** | Allow selected ports — SSH (22) |

![Step 1 — VM1 Networking tab](Screenshots/Screenshot%202026-03-04%20110348.png)

#### Edit Virtual Network

| Setting | Value |
|---------|-------|
| **VNet Name** | `devops-lab-vnet-sakit` |
| **Address space** | `172.16.0.0/16` (65,536 addresses) |
| **Subnet** | snet-austriaeast-1: 172.16.0.0 – 172.16.0.255 (/24) |

![Step 1 — Edit virtual network](Screenshots/Screenshot%202026-03-04%20110510.png)

![Step 1 — VM1 Networking (after VNet config)](Screenshots/Screenshot%202026-03-04%20110608.png)

![Step 1 — VM1 Networking (Review + create)](Screenshots/Screenshot%202026-03-04%20110824.png)

#### Review + Create & Key Download

![Step 1 — VM1 Review + create and SSH key download](Screenshots/Screenshot%202026-03-04%20111217.png)

#### Deployment Complete

![Step 1 — VM1 deployment complete](Screenshots/Screenshot%202026-03-04%20111407.png)

---

### VM 2 — `devops-lab-vm2-sakit`

#### Basics Tab

| Setting | Value |
|---------|-------|
| **Resource group** | `rg-vm-lab-sakit` (same as VM1) |
| **Virtual machine name** | `devops-lab-vm2-sakit` |
| **Region** | (Europe) Austria East |
| **Image** | Ubuntu Server 24.04 LTS – x64 Gen2 |
| **Authentication type** | SSH public key |
| **Username** | `mr-sakit` |
| **SSH public key source** | Use existing key stored in Azure |
| **Stored Keys** | `devops-lab-vm1-sakit_key` |

![Step 1 — VM2 Basics tab](Screenshots/Screenshot%202026-03-04%20111726.png)

![Step 1 — VM2 Admin account (reuse existing SSH key)](Screenshots/Screenshot%202026-03-04%20111745.png)

#### Disks Tab

| Setting | Value |
|---------|-------|
| **OS disk size** | Image default (30 GiB) |
| **OS disk type** | Standard SSD (locally-redundant storage) |
| **Delete with VM** | ✅ |

![Step 1 — VM2 Disks tab](Screenshots/Screenshot%202026-03-04%20111814.png)

#### Networking Tab

| Setting | Value |
|---------|-------|
| **Virtual network** | `devops-lab-vnet-sakit` (same VNet as VM1) |
| **Subnet** | snet-austriaeast-1 (172.16.0.0/24) |
| **Public IP** | (new) `devops-lab-vm2-sakit-ip` |
| **NIC network security group** | Basic |
| **Public inbound ports** | Allow selected ports — SSH (22) |

> **⚠️ Important:** Both VMs must be in the **same virtual network** so that the Load Balancer can reach them through a shared backend pool.

![Step 1 — VM2 Networking tab](Screenshots/Screenshot%202026-03-04%20111923.png)

#### Deployment Complete

![Step 1 — VM2 deployment complete](Screenshots/Screenshot%202026-03-04%20112108.png)

---

## 📌 Step 2 — Enable Port 80 (HTTP) on Both VMs

Go to each VM → **Networking** → **Network settings** → **Add inbound security rule**:

| Setting | Value |
|---------|-------|
| **Destination port ranges** | 80 |
| **Protocol** | Any |
| **Action** | Allow |
| **Service** | Custom |

> **Note:** Make sure to enable port 80 for **both** VMs if they have separate NSGs.

![Step 2 — VM1 Network settings — Add inbound rule for port 80](Screenshots/Screenshot%202026-03-04%20112300.png)

The screenshot shows VM1 details:

| Property | Value |
|----------|-------|
| **Public IP** | `68.210.100.90` |
| **Private IP** | `172.16.0.4` |
| **NSG** | `devops-lab-vm1-sakit-nsg` |

---

## 📌 Step 3 — Install Apache and Set Custom Content

SSH into each VM and install Apache:

```bash
sudo apt update
sudo apt install -y apache2
```

Verify Apache is running:

```bash
sudo systemctl status apache2
```

![Step 3 — Apache running on VM1](Screenshots/Screenshot%202026-03-04%20113725.png)

### Set custom index.html on VM1 (first server):

```bash
echo '<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Sakit Apache Page</title></head>
  <body style="font-family: sans-serif;">
    <h1>Hello,this is Sakit lab Apache server!</h1>
    <p>If you can read this,Sakit has achieved something 🎉</p>
    <p>This is the first server 🎉</p>
  </body>
</html>' | sudo tee /var/www/html/index.html > /dev/null
```

![Step 3 — Custom index.html on VM1 (first server)](Screenshots/Screenshot%202026-03-04%20123445.png)

### Set custom index.html on VM2 (second server):

```bash
echo '<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Sakit Apache Page</title></head>
  <body style="font-family: sans-serif;">
    <h1>Hello,this is Sakit lab Apache server!</h1>
    <p>If you can read this,Sakit has achieved something 🎉</p>
    <p>This is the second server 🎉</p>
  </body>
</html>' | sudo tee /var/www/html/index.html > /dev/null
```

![Step 3 — Custom index.html on VM2 (second server)](Screenshots/Screenshot%202026-03-04%20123526.png)

---

## 📌 Step 4 — Create the Azure Load Balancer

Navigate to **Load balancers** → **Create** → **Standard Load balancer**.

### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `rg-vm-lab-sakit` |
| **Name** | `devops-lb-sakit` |
| **Region** | Austria East |
| **SKU** | Standard |
| **Type** | Public |
| **Tier** | Regional |

![Step 4 — Load Balancers page → Create](Screenshots/Screenshot%202026-03-04%20123637.png)

![Step 4 — LB Basics tab](Screenshots/Screenshot%202026-03-04%20123843.png)

### Frontend IP Configuration Tab

Click **+ Add a frontend IP configuration**:

| Setting | Value |
|---------|-------|
| **Name** | `devops-lb-publicip-sakit` |
| **IP version** | IPv4 |
| **IP type** | IP address |
| **Public IP address** | (new) `devops-public-ip-sakit` |

![Step 4 — Frontend IP configuration](Screenshots/Screenshot%202026-03-04%20124527.png)

### Backend Pools Tab

Click **+ Add a backend pool**:

| Setting | Value |
|---------|-------|
| **Name** | `devops-lb-pool-sakit` |
| **Virtual network** | `devops-lab-vnet-sakit` (rg-vm-lab-sakit) |
| **Backend Pool Configuration** | NIC |

Click **+ Add** → Select both VMs:

| Virtual Machine | Resource Group | IP Address |
|----------------|---------------|------------|
| `devops-lab-vm1-sakit` | rg-vm-lab-sakit | 172.16.0.4 |
| `devops-lab-vm2-sakit` | rg-vm-lab-sakit | 172.16.0.5 |

![Step 4 — Backend pools tab](Screenshots/Screenshot%202026-03-04%20124622.png)

![Step 4 — Add backend pool with both VMs](Screenshots/Screenshot%202026-03-04%20124835.png)

### Inbound Rules Tab

Click **+ Add a load balancing rule**:

| Setting | Value |
|---------|-------|
| **Name** | `devops-lb-rule-sakit` |
| **IP version** | IPv4 |
| **Frontend IP address** | `devops-lb-publicip-sakit` |
| **Backend pool** | `devops-lb-pool-sakit` |
| **Protocol** | TCP |
| **Port** | 80 |
| **Backend port** | 80 |
| **Health probe** | (new) `healthcheck-sakit` (TCP:80) |

![Step 4 — Add load balancing rule](Screenshots/Screenshot%202026-03-04%20130024.png)

![Step 4 — Inbound rules summary](Screenshots/Screenshot%202026-03-04%20182421.png)

### Review + Create

![Step 4 — Review + create (Validation passed)](Screenshots/Screenshot%202026-03-04%20182450.png)

---

## 📌 Step 5 — Verify the Load Balancer

### Load Balancer Overview

After deployment, the LB overview page confirms all components:

| Property | Value |
|----------|-------|
| **Resource group** | rg-lb-sakit |
| **SKU** | Standard |
| **Tier** | Regional |
| **Backend pool** | devops-lb-pool-sakit (2 virtual machines) |
| **Load balancing rule** | devops-lb-rule-sakit (Tcp/80) |
| **Health probe** | healthcheck-sakit (Tcp:80) |
| **Frontend IP address** | `20.33.40.107` (devops-public-ip-sakit) |

![Step 5 — Load Balancer Overview](Screenshots/Screenshot%202026-03-05%20072201.png)

### Frontend IP Configuration

![Step 5 — Frontend IP configuration (20.33.40.107)](Screenshots/Screenshot%202026-03-05%20072402.png)

---

## 📌 Step 6 — Test Load Balancing

Open the Load Balancer's public IP (`http://20.33.40.107`) in a browser.

Refreshing the page multiple times shows that the LB distributes traffic between the two VMs in a **round-robin** fashion:

### Response from Second Server:

![Step 6 — Browser showing "second server" via LB IP](Screenshots/Screenshot%202026-03-05%20073444.png)

### Response from First Server:

![Step 6 — Browser showing "first server" via LB IP](Screenshots/Screenshot%202026-03-05%20073952.png)

The content alternates between **"This is the first server 🎉"** and **"This is the second server 🎉"**, confirming that the Azure Load Balancer is distributing requests across both backend VMs.

---

## 📌 Step 7 — Clean Up

To avoid ongoing charges:

1. Navigate to **Resource groups** → `rg-vm-lab-sakit`
2. Click **Delete resource group** → confirm the name
3. This deletes all resources: VMs, VNet, NSG, Public IPs, Load Balancer, and disks

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| **Azure Load Balancer** | Layer 4 service that distributes incoming traffic among healthy backend VMs |
| **Frontend IP** | The public-facing IP address that clients connect to |
| **Backend Pool** | Group of VMs that receive traffic from the Load Balancer |
| **Health Probe** | Monitors VM health; unhealthy VMs are removed from rotation |
| **Load Balancing Rule** | Maps frontend port to backend port and links to a health probe |
| **Round-Robin** | Default distribution — requests alternate between available servers |
| **High Availability** | If one VM goes down, the LB routes all traffic to the healthy VM |
| **Same VNet Requirement** | Backend VMs must be in the same virtual network as the LB's backend pool |
