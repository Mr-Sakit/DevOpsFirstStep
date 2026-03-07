# Lab 3 — Provision an Azure Application Gateway with Path-Based Routing

> An **Application Gateway** is a Layer 7 (HTTP/HTTPS) load balancer that can make routing decisions based on URL paths or host headers. Unlike a Layer 4 Load Balancer (Lab 2), it inspects application-level attributes to route traffic intelligently.

In this lab, an **Azure Application Gateway (Standard V2)** was configured with **URL path-based routing** to direct traffic to two different Apache web servers:

| URL Path | Routed To |
|----------|-----------|
| `/` (default) | VM1 — Site1 |
| `/site1/*` | VM1 — Site1 |
| `/site2/*` | VM2 — Site2 |

> **⚠️ Using previous labs:** This lab reuses the `devops-lab-vm1-sakit` and `devops-lab-vm2-sakit` virtual machines, `devops-lab-vnet-sakit` virtual network, and `rg-lb-sakit` resource group created in **Lab 2**. There is no need to create a new resource — just add the Application Gateway and its associated subnet.

---

## 📌 Step 1 — Prepare Web Content on Both VMs

> **Note:** Both VMs were already created and have Apache installed from **Lab 2** (Load Balancer lab). Here we update the web content for path-based routing.

### VM1 — Set Site1 Content

```bash
# Set the main page for VM1
echo "<h1>Site1 content from VM1 (Main Page)</h1>" | sudo tee /var/www/html/index.html

# Create a subdirectory for path-based routing
sudo mkdir -p /var/www/html/site1
echo "<h1>Site1 content from VM1 (path-based test)</h1>" | sudo tee /var/www/html/site1/index.html
```

Verify with curl:
```bash
curl 20.54.84.106/site1/
# Output: <h1>Site1 content from VM1 (path-based test)</h1>
```

![Step 1 — VM1 content update and curl test](Screenshot%202026-03-05%20090338.png)

### VM2 — Set Site2 Content

```bash
# Set the main page for VM2
echo "<h1>Site2 content from VM1 (Main Page)</h1>" | sudo tee /var/www/html/index.html

# Create a subdirectory for path-based routing
sudo mkdir -p /var/www/html/site2
echo "<h1>Site2 content from VM2 (path-based test)</h1>" | sudo tee /var/www/html/site2/index.html
```

![Step 1 — VM2 content update](Screenshot%202026-03-05%20090352.png)

---

## 📌 Step 2 — Create the Application Gateway

Navigate to **Create a resource** → Search for **Application Gateway** → Click **Create**.

![Step 2 — Application Gateway in Marketplace](Screenshot%202026-03-05%20090554.png)

### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `rg-lb-sakit` |
| **Application gateway name** | `devops-ag-sakit` |
| **Region** | North Europe |
| **Tier** | Standard V2 |
| **Enable autoscaling** | Yes |
| **Minimum instance count** | 0 |
| **Maximum instance count** | 10 |
| **IP address type** | IPv4 only |
| **HTTP2** | Enabled |

![Step 2 — Basics tab (top)](Screenshot%202026-03-05%20090916.png)

#### Dedicated Subnet for Application Gateway

> **⚠️ Important:** Application Gateway must be deployed in its own **dedicated subnet** — no other resources can share this subnet.

A new subnet was created within the existing VNet:

| Setting | Value |
|---------|-------|
| **Virtual network** | `devops-vnet-lb-sakit` |
| **Subnet name** | `devops-ag-subnet-sakit` |
| **Address range** | `172.16.1.0/24` (172.16.1.0 – 172.16.1.255) |

![Step 2 — Add dedicated subnet](Screenshot%202026-03-05%20091016.png)

![Step 2 — Basics tab with VNet and subnet configured](Screenshot%202026-03-05%20091238.png)

### Frontends Tab

| Setting | Value |
|---------|-------|
| **Frontend IP address type** | Public |
| **Public IP address** | (new) `devops-ag-publicip-sakit` |
| **SKU** | Standard |
| **Assignment** | Static |
| **Availability zone** | ZoneRedundant |

![Step 2 — Frontends tab with Public IP](Screenshot%202026-03-05%20091407.png)

### Backends Tab

Two separate backend pools were created — one per VM:

#### Backend Pool 1 (VM1)

| Setting | Value |
|---------|-------|
| **Name** | `backendPool1` |
| **Target type** | Virtual machine |
| **Target** | `lb-vm1-sakit` (VM1 NIC) |

![Step 2 — backendPool1 with VM1](Screenshot%202026-03-05%20091718.png)

#### Backend Pool 2 (VM2)

| Setting | Value |
|---------|-------|
| **Name** | `backendPool2` |
| **Target type** | Virtual machine |
| **Target** | `lb-vm2-sakit` (VM2 NIC) |

![Step 2 — backendPool2 with VM2](Screenshot%202026-03-05%20091817.png)

---

## 📌 Step 3 — Configure Routing Rules (Configuration Tab)

### Add HTTP Listener

| Setting | Value |
|---------|-------|
| **Rule name** | `path_based_rule` |
| **Priority** | 100 |
| **Listener name** | `http_listener` |
| **Frontend IP** | Public IPv4 |
| **Protocol** | HTTP |
| **Port** | 80 |
| **Listener type** | Basic |

![Step 3 — Listener configuration](Screenshot%202026-03-05%20092831.png)

### Add Backend Settings

| Setting | Value |
|---------|-------|
| **Backend settings name** | `backend_settings` |
| **Backend protocol** | HTTP |
| **Backend port** | 80 |
| **Cookie-based affinity** | Disabled |
| **Connection draining** | Disabled |
| **Request time-out** | 20 seconds |
| **Override with new host name** | No |

![Step 3 — Backend settings](Screenshot%202026-03-05%20093527.png)

### Configure Backend Targets and Path-Based Routing

#### Default Target (for unmatched paths)

| Setting | Value |
|---------|-------|
| **Target type** | Backend pool |
| **Backend target** | `backendPool1` (VM1) |
| **Backend settings** | `backend_settings` |

![Step 3 — Default backend target (backendPool1)](Screenshot%202026-03-05%20093914.png)

Click **"Add multiple targets to create a path-based rule"** to enable path-based routing.

#### Path Rule — `/site2/*` → VM2

| Setting | Value |
|---------|-------|
| **Path** | `/site2/*` |
| **Target name** | `Site2Rule` |
| **Backend settings** | `backend_settings` |
| **Backend target** | `backendPool2` |

![Step 3 — Path rule for /site2/* to backendPool2](Screenshot%202026-03-05%20094303.png)

#### Final Routing Rule Summary

After adding path rules for both `/site1/*` and `/site2/*`:

| Path | Target Name | Backend Setting | Backend Pool |
|------|------------|----------------|-------------|
| `/site2/*` | Site2Rule | backend_settings | backendPool2 |
| `/site1/*` | Site1Rule | backend_settings | backendPool1 |
| Default | — | backend_settings | backendPool1 |

![Step 3 — Complete routing rule with path-based rules](Screenshot%202026-03-05%20095502.png)

---

## 📌 Step 4 — Review + Create

Validation passed. Summary of the Application Gateway configuration:

| Section | Setting | Value |
|---------|---------|-------|
| **Basics** | Name | `devops-ag-sakit` |
| | Region | North Europe |
| | Tier | Standard_v2 |
| | Autoscaling | Enabled (0–10) |
| | VNet | `devops-vnet-lb-sakit` |
| | Subnet | `devops-ag-subnet-sakit` (172.16.1.0/24) |
| **Frontends** | Public IP | `devops-ag-publicip-sakit` (Standard, Static) |

![Step 4 — Review + create (Validation passed)](Screenshot%202026-03-05%20095547.png)

---

## 📌 Step 5 — Test Path-Based Routing

The Application Gateway's public IP address: **`20.82.210.216`**

### Test 1 — Default Path (`/`)

URL: `http://20.82.210.216/`

**Result:** "Site1 content from VM1 (Main Page)" → Routed to **VM1** (default backend) ✅

### Test 2 — `/site1/` Path

URL: `http://20.82.210.216/site1/`

**Result:** "Site1 content from VM1 (path-based test)" → Routed to **VM1** via Site1Rule ✅

### Test 3 — `/site2/` Path

URL: `http://20.82.210.216/site2/`

**Result:** "Site2 content from VM2 (path-based test)" → Routed to **VM2** via Site2Rule ✅

![Step 5 — All three test results showing path-based routing](Screenshot%202026-03-05%20102501.png)

---

## 📌 Step 6 — Clean Up

To avoid ongoing charges:

1. Navigate to **Resource groups** → `rg-lb-sakit`
2. Click **Delete resource group** → confirm the name
3. This deletes the Application Gateway, VMs, VNet, subnets, Public IPs, and all related resources

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| **Application Gateway** | Layer 7 (HTTP/HTTPS) load balancer with advanced routing capabilities |
| **Path-Based Routing** | Routes requests to different backends based on the URL path (e.g., `/site1/*` vs `/site2/*`) |
| **Dedicated Subnet** | AG must be in its own subnet — no other resources allowed |
| **Backend Pool** | Group of servers receiving traffic; AG supports multiple pools |
| **Backend Settings** | Defines how AG communicates with backends (protocol, port, timeout) |
| **Listener** | Listens on a specific port/protocol for incoming traffic |
| **Routing Rule** | Links a listener to backend pools, optionally with path-based rules |
| **Standard V2** | Recommended tier with autoscaling, zone redundancy, and WAF support |

### Load Balancer vs. Application Gateway

| Feature | Load Balancer (Lab 2) | Application Gateway (Lab 3) |
|---------|----------------------|---------------------------|
| **OSI Layer** | Layer 4 (Transport) | Layer 7 (Application) |
| **Routing** | IP + Port based | URL path, host header, cookies |
| **Protocol** | TCP/UDP | HTTP/HTTPS |
| **SSL Termination** | ❌ | ✅ |
| **WAF** | ❌ | ✅ (optional) |
| **Use Case** | Simple traffic distribution | Content-based routing, web apps |
