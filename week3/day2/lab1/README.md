# Lab 1 — Provision a Linux Azure VM with Custom Virtual Network

In this lab, a Linux virtual machine was provisioned on Azure with a fully custom network infrastructure — including a Virtual Network (VNet), subnet, Network Security Group (NSG), public IP address, and Network Interface (NIC).

---

## 📌 Step 1 — Create a Resource Group

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group name** | `devops-vnet-lab-sakit` |
| **Region** | (Europe) Austria East |

![Step 1 — Create resource group](Screenshot%202026-03-03%20115413.png)

---

## 📌 Step 2 — Create a Virtual Network (VNet) and Subnet

> An Azure Virtual Network (VNet) is an isolated private network in the cloud. It enables Azure resources (like VMs) to securely communicate with each other, with the internet, and with on-premises networks.

### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource Group** | `devops-vnet-lab-sakit` |
| **Virtual network name** | `devops-vnet-sakit` |
| **Region** | (Europe) Austria East |

![Step 2 — Search Virtual Networks](Screenshot%202026-03-03%20115516.png)

![Step 2 — VNet Basics tab](Screenshot%202026-03-03%20120221.png)

### IP Addresses Tab

| Setting | Value |
|---------|-------|
| **Address space** | `10.2.0.0/16` (65,536 addresses) |
| **Subnet name** | `devops-subnet-sakit` |
| **Subnet address range** | `10.2.0.0/24` (256 addresses, 10.2.0.0 – 10.2.0.255) |

![Step 2 — IP Addresses tab (default address space)](Screenshot%202026-03-03%20120429.png)

![Step 2 — Edit subnet (devops-subnet-sakit, 10.2.0.0/24)](Screenshot%202026-03-03%20121407.png)

![Step 2 — Subnet configured](Screenshot%202026-03-03%20121456.png)

### Review + Create

Validation passed. Click **Create**.

![Step 2 — VNet Review + create (Validation passed)](Screenshot%202026-03-03%20121538.png)

### Deployment Complete

![Step 2 — VNet deployment complete](Screenshot%202026-03-03%20121659.png)

### VNet Overview

| Property | Value |
|----------|-------|
| **Resource group** | devops-vnet-lab-sakit |
| **Location** | Austria East |
| **Address space** | 10.2.0.0/16 |
| **Subnets** | 1 subnet |
| **DNS servers** | Azure provided DNS service |

![Step 2 — VNet Overview page](Screenshot%202026-03-03%20121803.png)

---

## 📌 Step 3 — Create a Network Security Group (NSG)

> A Network Security Group acts as a cloud firewall. It contains inbound and outbound security rules that allow or deny traffic to your VM based on source/destination IP, port, and protocol.

### Create NSG

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource Group** | `devops-vnet-lab-sakit` |
| **Name** | `devops-nsg-sakit` |
| **Region** | Austria East |

![Step 3 — Search Network security groups](Screenshot%202026-03-03%20121909.png)

![Step 3 — NSG Create page](Screenshot%202026-03-03%20121941.png)

![Step 3 — Create NSG (devops-nsg-sakit)](Screenshot%202026-03-03%20122110.png)

### Add SSH Inbound Rule

Navigate to **Inbound security rules** → click **+ Add**.

Default rules shown:

| Priority | Name | Port | Action |
|----------|------|------|--------|
| 65000 | AllowVnetInBound | Any | Allow |
| 65001 | AllowAzureLoadBalancerInBound | Any | Allow |
| 65500 | DenyAllInBound | Any | Deny |

Add a new rule to allow SSH:

| Setting | Value |
|---------|-------|
| **Source** | Any |
| **Source port ranges** | * |
| **Destination** | Any |
| **Destination port ranges** | 22 |
| **Protocol** | TCP |
| **Action** | Allow |
| **Priority** | 100 |
| **Name** | `Allow-SSH` |

![Step 3 — NSG Inbound security rules (default rules + Add)](Screenshot%202026-03-03%20125934.png)

![Step 3 — Add inbound SSH rule](Screenshot%202026-03-03%20130027.png)

![Step 3 — Allow-SSH rule added successfully](Screenshot%202026-03-04%20082314.png)

---

## 📌 Step 4 — Create a Public IP Address

> A public IP address is needed to communicate with the VM from the internet (e.g., to SSH into it).

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource Group** | `devops-vnet-lab-sakit` |
| **Name** | `devops-publicip-sakit` |
| **Region** | (Europe) Austria East |
| **IP Version** | IPv4 |
| **SKU** | Standard |
| **Availability zone** | Zone-redundant |
| **Tier** | Regional |
| **IP address assignment** | Static |
| **Routing preference** | MicrosoftNetwork |

![Step 4 — Search Public IP addresses](Screenshot%202026-03-04%20082615.png)

![Step 4 — Public IP addresses Create](Screenshot%202026-03-04%20082646.png)

![Step 4 — Create public IP address](Screenshot%202026-03-04%20082936.png)

![Step 4 — Public IP Review + create (Validation passed)](Screenshot%202026-03-04%20083123.png)

---

## 📌 Step 5 — Create a Network Interface (NIC)

> The NIC is the network adapter that your VM will use to connect to the VNet. It is associated with the VNet, subnet, NSG, and public IP.

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource Group** | `devops-vnet-lab-sakit` |
| **Name** | `devops-nic-sakit` |
| **Region** | Austria East |
| **Virtual network** | (New) vnet-austriaeast-2 (devops-vnet-lab-sakit) |
| **Subnet** | (New) snet-austriaeast-1 |
| **IP version** | IPv4 |
| **Private IP address assignment** | Dynamic |

![Step 5 — Search Network Interfaces](Screenshot%202026-03-04%20083228.png)

![Step 5 — Network Interfaces Create](Screenshot%202026-03-04%20083253.png)

![Step 5 — Create network interface](Screenshot%202026-03-04%20083820.png)

![Step 5 — NIC deployment complete](Screenshot%202026-03-04%20084339.png)

---

## 📌 Step 6 — Provision the Linux Virtual Machine

With all networking components in place, the VM was created and attached to them.

### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `devops-vnet-lab-sakit` |
| **Virtual machine name** | `devops-vm-sakit` |
| **Region** | (Europe) Austria East |
| **Availability options** | Availability zone |
| **Availability zone** | Zone 1 |
| **Security type** | Standard |
| **Image** | Ubuntu Server 24.04 LTS – x64 Gen2 |
| **Size** | Standard_D2s_v3 (2 vcpus, 8 GiB memory) |
| **Authentication type** | SSH public key |
| **Username** | `mr-sakit` |
| **SSH public key source** | Generate new key pair |
| **Key pair name** | `devops-vm-sakit_key` |
| **Public inbound ports** | None |

> **Note:** Public inbound ports are set to **None** here because we already created the NSG (`devops-nsg-sakit`) with an SSH allow rule in Step 3.

![Step 6 — Virtual machines Create](Screenshot%202026-03-04%20084754.png)

![Step 6 — Basics tab (Project & Instance details)](Screenshot%202026-03-04%20085138.png)

![Step 6 — Basics tab (Size, Admin account, Inbound ports)](Screenshot%202026-03-04%20085215.png)

### Disks Tab

| Setting | Value |
|---------|-------|
| **OS disk size** | Image default (30 GiB) |
| **OS disk type** | Standard SSD (locally-redundant storage) |
| **Delete with VM** | ✅ |
| **Key management** | Platform-managed key |

![Step 6 — Disks tab](Screenshot%202026-03-04%20085314.png)

### Networking Tab

| Setting | Value |
|---------|-------|
| **Virtual network** | `devops-vnet-sakit` (devops-vnet-lab-sakit) |
| **Subnet** | `devops-subnet-sakit` (10.2.0.0 – 10.2.0.255) |
| **Public IP** | `devops-publicip-sakit` |
| **NIC network security group** | Advanced |
| **Configure NSG** | (new) `devops-vm-sakit-nsg` |
| **Delete public IP when VM is deleted** | ✅ |
| **Load balancing** | None |

![Step 6 — Networking tab](Screenshot%202026-03-04%20090028.png)

### Review + Create

Validation passed. Summary includes all networking components linked to the VM.

| Summary | Value |
|---------|-------|
| **Virtual network** | devops-vnet-sakit |
| **Subnet** | devops-subnet-sakit |
| **Public IP** | devops-publicip-sakit |
| **NIC network security group** | devops-nsg-sakit |

![Step 6 — Review + create (Validation passed)](Screenshot%202026-03-04%20090142.png)

### Deployment Complete

![Step 6 — VM deployment complete](Screenshot%202026-03-04%20090705.png)

---

## 📌 Step 7 — Test Connectivity via SSH

Using the downloaded private key (`devops-vm-sakit_key.pem`), SSH into the VM:

```bash
ssh -i devops-vm-sakit_key.pem mr-sakit@68.210.64.128
```

| Property | Value |
|----------|-------|
| **Public IP** | `68.210.64.128` |
| **Private IP (eth0)** | `10.2.0.4` |
| **OS** | Ubuntu 24.04.3 LTS |
| **Kernel** | 6.14.0-1017-azure x86_64 |
| **Hostname** | `devops-vm-sakit` |

The SSH connection succeeded, confirming that the NSG (`devops-nsg-sakit`) correctly allows inbound traffic on port 22.

![Step 7 — SSH connection to the VM](Screenshot%202026-03-04%20091719.png)

---

## 📌 Step 8 — Clean Up

To avoid ongoing charges:

1. Navigate to **Resource groups** → `devops-vnet-lab-sakit`
2. Click **Delete resource group** → confirm the name
3. This deletes all resources: VM, VNet, NSG, NIC, Public IP, and OS disk

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| **Virtual Network (VNet)** | An isolated private network in Azure for secure communication between resources |
| **Subnet** | A segment within a VNet that organizes resources and defines IP address ranges |
| **Network Security Group (NSG)** | Cloud firewall with rules that filter inbound/outbound traffic by IP, port, and protocol |
| **Public IP Address** | Enables internet-facing access to the VM (e.g., for SSH) |
| **Network Interface (NIC)** | The virtual network adapter that connects a VM to a VNet |
| **SSH Key Authentication** | More secure than password-based access; uses RSA key pair |
| **Inbound Port Rules** | Priority-based rules — lower numbers = higher priority (e.g., 100 > 65500) |
| **Resource Group** | Logical container — deleting the group removes all contained resources |
