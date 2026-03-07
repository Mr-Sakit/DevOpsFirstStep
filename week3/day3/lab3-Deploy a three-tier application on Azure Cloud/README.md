# Lab 3 — Deploy a Three-Tier E-Commerce Application on Azure

> **Assignment:** Deploy a three-tier web application end-to-end on Azure Cloud with an **Application Gateway** for unified access.

## Architecture Overview

```
                    ┌──────────────────────────┐
                    │   Application Gateway     │
                    │   ag-e-commerce-sakit      │
                    │   Public IP: 20.54.96.5   │
                    └────────┬─────────┬────────┘
                             │         │
                    /        │         │  /api/*
                    (default)│         │
               ┌─────────────┘         └─────────────┐
               ▼                                     ▼
    ┌─────────────────────┐            ┌─────────────────────┐
    │  Frontend VM (VM1)  │            │  Backend VM (VM2)   │
    │  lb-vm1-sakit       │            │  lb-vm2-sakit       │
    │  IP: 20.54.84.106   │            │  IP: 40.67.247.186  │
    │  Port: 3000 (React) │            │  Port: 3001 (API)   │
    └─────────────────────┘            └──────────┬──────────┘
                                                  │
                                       ┌──────────▼──────────┐
                                       │  Azure SQL Database  │
                                       │  devops-sqldb-sakit   │
                                       │  (Private access)    │
                                       └──────────────────────┘
```

| Tier | Technology | Host | Port |
|------|-----------|------|------|
| **Frontend** | React (Node.js) | `lb-vm1-sakit` | 3000 |
| **Backend** | Node.js API | `lb-vm2-sakit` | 3001 |
| **Database** | Azure SQL Database | `devops-sql-server-sakit` | 1433 |

> **⚠️ Using previous labs:** This lab reuses the `lb-vm1-sakit` and `lb-vm2-sakit` virtual machines and `devops-vnet-lb-sakit` virtual network created in **Day 2 / Lab 2** (Load Balancer lab). The Azure SQL Database `devops-sqldb-sakit` was created in **Day 3 / Lab 2**.

---

## 📌 Step 1 — Configure SQL Database Firewall (Backend VM Only)

Navigate to **SQL Server** `devops-sql-server-sakit` → **Networking** → **Firewall rules**:

| Setting | Value |
|---------|-------|
| **Public network access** | Selected networks |
| **Rule name** | `BackendVM` |
| **Start IPv4 address** | `40.67.247.186` |
| **End IPv4 address** | `40.67.247.186` |

> **🔒 Security:** Only the Backend VM's IP is allowed — no public access. This ensures the database is only accessible from the backend server.

![Step 1 — SQL Server firewall with BackendVM rule](Screenshots/Screenshot%202026-03-05%20202719.png)

---

## 📌 Step 2 — Deploy the Backend Application (VM2)

### 2.1 — Verify Prerequisites and Clone the Code

SSH into `lb-vm2-sakit` and set up the backend:

```bash
# Check versions
git --version         # 2.43.0
node -v               # v18.19.1
npm -v                # 9.2.0

# Create working directory and clone repo
mkdir lab3
cd lab3
git clone https://github.com/saurabhd2106/ecommerce-app-three-tier-azure-db-ih

# Navigate to backend directory
cd ecommerce-app-three-tier-azure-db-ih/ecommerce-app-backend
```

![Step 2.1 — Git clone and navigate to backend directory](Screenshots/Screenshot%202026-03-05%20211402.png)

### 2.2 — Create Backend `.env` File

```bash
nano .env
```

```env
# Server Configuration
PORT=3001
NODE_ENV=development

# Azure SQL Database Configuration
DB_SERVER=devops-sql-server-sakit.database.windows.net
DB_NAME=devops-sqldb-sakit
DB_USER=mr-sakit
DB_PASSWORD=<your_password>
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=false
DB_CONNECTION_TIMEOUT=30000

# JWT Configuration
JWT_SECRET=this-sentence-should-be-as-long-as-possible-to-ensure-security-102030
JWT_EXPIRES_IN=7d

# CORS Configuration
CORS_ORIGIN=http://localhost:3000

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

![Step 2.2 — Backend .env configuration](Screenshots/Screenshot%202026-03-05%20211446.png)

### 2.3 — Create Frontend `.env` File

```bash
cd ../ecommerce-app-frontend
echo "REACT_APP_API_URL=http://localhost:3001/api" > .env
cat .env
# Output: REACT_APP_API_URL=http://localhost:3001/api
```

![Step 2.3 — Frontend .env file](Screenshots/Screenshot%202026-03-05%20211723.png)

### 2.4 — Install, Build, and Start the Backend

```bash
cd ../ecommerce-app-backend
npm install       # 667 packages installed
npm run build     # tsc (TypeScript compilation)
npm start         # node dist/server.js
```

**Backend output:**

```
Connected to Azure SQL Database
🔄 Initializing database...
📋 Creating database tables...
🌱 Inserting sample data...
🔧 Creating triggers...
✅ Database initialization completed successfully!
🚀 Server running on port 3001
🏠 Environment: development
🔗 Health check: http://localhost:3001/health
📁 API endpoints: http://localhost:3001/api
```

![Step 2.4 — npm install and backend startup](Screenshots/Screenshot%202026-03-05%20214128.png)
![Step 2.4 — Backend running with DB initialized](Screenshots/Screenshot%202026-03-05%20214145.png)

### 2.5 — Verify Backend API

```bash
curl http://localhost:3001/api/products
```

Returns JSON with 10 products (Wireless Headphones, Smartphone, Laptop, Running Shoes, Yoga Mat, Coffee Maker, Bluetooth Speaker, Backpack, Water Bottle, Gaming Mouse).

![Step 2.5 — curl API products response](Screenshots/Screenshot%202026-03-05%20214203.png)

---

## 📌 Step 3 — Deploy the Frontend Application (VM1)

### 3.1 — Clone and Configure

SSH into `lb-vm1-sakit`:

```bash
# Check versions
git --version         # 2.43.0
node -v               # v18.19.1
npm -v                # 9.2.0

# Clone repo and navigate to frontend
mkdir lab3
cd lab3
git clone https://github.com/saurabhd2106/ecommerce-app-three-tier-azure-db-ih
cd ecommerce-app-three-tier-azure-db-ih/ecommerce-app-frontend

# Set the API URL to the Backend VM's public IP
echo "REACT_APP_API_URL=http://40.67.247.186:3001/api" > .env
cat .env
# Output: REACT_APP_API_URL=http://40.67.247.186:3001/api

# Install dependencies
npm install
```

![Step 3.1 — Frontend clone and setup on VM1](Screenshots/Screenshot%202026-03-05%20220648.png)

---

## 📌 Step 4 — Configure NSG Rules

Open the required ports on both VMs:

### VM1 — Frontend NSG (`lb-vm1-sakit-nsg`)

| Priority | Name | Port | Protocol | Source | Destination |
|----------|------|------|----------|--------|-------------|
| 101 | AllowFrontend3000 | 3000 | Any | Any | Any |
| 300 | SSH | 22 | TCP | Any | Any |
| 310 | enableport | 80 | Any | Any | Any |

### VM2 — Backend NSG (`lb-vm2-sakit-nsg`)

| Priority | Name | Port | Protocol | Source | Destination |
|----------|------|------|----------|--------|-------------|
| 100 | AllowBackend3001 | 3001 | Any | Any | Any |
| 300 | SSH | 22 | TCP | Any | Any |
| 310 | enablevm2port | 80 | Any | Any | Any |

![Step 4 — NSG rules for VM1 and VM2](Screenshots/Screenshot%202026-03-05%20232055.png)

---

## 📌 Step 5 — Verify Frontend Access (Direct)

Access the frontend directly via VM1 IP → `http://20.54.84.106:3000`:

The e-commerce store homepage loads showing "Welcome to Our E-commerce Store" with Shop Now and Browse Categories buttons.

![Step 5 — Frontend homepage via direct IP](Screenshots/Screenshot%202026-03-05%20232514.png)

---

## 📌 Step 6 — Configure the Application Gateway

### 6.1 — Basics Tab

Navigate to **Application gateways** → **Create**:

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `rg-sql-lab-sakit` |
| **Application gateway name** | `ag-e-commerce-sakit` |
| **Region** | North Europe |
| **Tier** | Standard V2 |
| **Enable autoscaling** | Yes |
| **Minimum instance count** | 0 |
| **Maximum instance count** | 10 |
| **HTTP2** | Enabled |
| **Virtual network** | `devops-vnet-lb-sakit` |
| **Subnet** | `ag-lab-subnet-sakit` (172.16.2.0/24) — *new* |

![Step 6.1 — AG Basics tab](Screenshots/Screenshot%202026-03-06%20082555.png)

### New Subnet for Application Gateway

| Setting | Value |
|---------|-------|
| **Name** | `ag-lab-subnet-sakit` |
| **IPv4 address range** | 172.16.0.0/16 |
| **Starting address** | 172.16.2.0 |
| **Size** | /24 (256 addresses) |

![Step 6.1 — Add subnet for AG](Screenshots/Screenshot%202026-03-06%20083241.png)
![Step 6.1 — Basics tab completed with subnet](Screenshots/Screenshot%202026-03-06%20083710.png)

### 6.2 — Frontends Tab

| Setting | Value |
|---------|-------|
| **Frontend IP address type** | Public |
| **Public IPv4 address** | (New) `ag-public-ip-sakit` |

![Step 6.2 — Frontends tab](Screenshots/Screenshot%202026-03-06%20083719.png)

### 6.3 — Backends Tab

Two backend pools created:

| Backend Pool | Target | NIC |
|-------------|--------|-----|
| `backend-pool` | 1 target | `lb-vm2-sakit937-7348e6ee` |
| `frontend-pool` | 1 target | `lb-vm1-sakit615-ada45396` |

![Step 6.3 — Backend pools](Screenshots/Screenshot%202026-03-06%20083733.png)

### 6.4 — Configuration Tab — Routing Rule

**Routing rule:** `ecommerce-routing-rule` (Priority: 100)

#### Listener

| Setting | Value |
|---------|-------|
| **Listener name** | `http-listener` |
| **Frontend IP** | Public IPv4 |
| **Protocol** | HTTP |
| **Port** | 80 |
| **Listener type** | Basic |

![Step 6.4 — Routing rule listener](Screenshots/Screenshot%202026-03-06%20084030.png)

#### Backend Targets (Default)

| Setting | Value |
|---------|-------|
| **Target type** | Backend pool |
| **Backend target** | `frontend-pool` |
| **Backend settings** | `frontend-http-settings` |

**Frontend HTTP settings:**

| Setting | Value |
|---------|-------|
| **Backend settings name** | `frontend-http-settings` |
| **Backend protocol** | HTTP |
| **Backend port** | 3000 |
| **Request time-out** | 20 seconds |
| **Override hostname** | No |

![Step 6.4 — Backend targets (default to frontend)](Screenshots/Screenshot%202026-03-06%20084058.png)
![Step 6.4 — Frontend HTTP settings](Screenshots/Screenshot%202026-03-06%20084142.png)

#### Path-Based Rule — `/api/*`

Click **Add multiple targets to create a path-based rule**:

| Setting | Value |
|---------|-------|
| **Path** | `/api/*` |
| **Target name** | `api-route` |
| **Backend settings** | `backend-http-settings` |
| **Backend target** | `backend-pool` |

**Backend HTTP settings:**

| Setting | Value |
|---------|-------|
| **Backend settings name** | `backend-http-settings` |
| **Backend protocol** | HTTP |
| **Backend port** | 3001 |
| **Request time-out** | 20 seconds |
| **Override hostname** | No |

![Step 6.4 — Path-based rule /api/*](Screenshots/Screenshot%202026-03-06%20084402.png)
![Step 6.4 — Backend HTTP settings (port 3001)](Screenshots/Screenshot%202026-03-06%20084437.png)
![Step 6.4 — Path rule completed](Screenshots/Screenshot%202026-03-06%20084507.png)

#### Final Configuration Summary

| URL Path | Routing | Backend Pool | Port |
|----------|---------|-------------|------|
| `/` (default) | `ecommerce-routing-rule` | `frontend-pool` | 3000 |
| `/api/*` | `api-route` | `backend-pool` | 3001 |

![Step 6.4 — Final routing configuration](Screenshots/Screenshot%202026-03-06%20084655.png)

### 6.5 — AG Deployed

| Property | Value |
|----------|-------|
| **Resource group** | rg-sql-lab-sakit |
| **Virtual network/subnet** | devops-vnet-lb-sakit/ag-lab-subnet-sakit |
| **Location** | North Europe (Zone 1, 2, 3) |
| **Frontend public IP** | 20.54.96.5 (`ag-public-ip-sakit`) |
| **Tier** | Standard V2 |

![Step 6.5 — AG overview](Screenshots/Screenshot%202026-03-06%20094500.png)

---

## 📌 Step 7 — Update .env Files for Application Gateway IP

Now that the AG is deployed (IP: `20.54.96.5`), update both config files:

### Frontend `.env` (on VM1)

```env
REACT_APP_API_URL=http://20.54.96.5/api
```

![Step 7 — Frontend .env updated with AG IP](Screenshots/Screenshot%202026-03-06%20094649.png)

### Backend `.env` — CORS (on VM2)

```env
CORS_ORIGIN=http://20.54.96.5
```

![Step 7 — Backend CORS updated with AG IP](Screenshots/Screenshot%202026-03-06%20095003.png)

> **Important:** After updating `.env` files, rebuild and restart both apps:
> ```bash
> # Backend (VM2)
> rm -rf node_modules && npm install && npm run build && npm start
>
> # Frontend (VM1)
> rm -rf node_modules && npm install && npm run build && npm start
> ```

---

## 📌 Step 8 — Verify End-to-End via Application Gateway

### 8.1 — Product Page via AG

Access `http://20.54.96.5/products/1` — the product detail page loads (Wireless Headphones, $199.99). Backend logs show requests arriving from AG subnet IPs (172.16.2.4, 172.16.2.5).

![Step 8.1 — Product detail page via AG + backend logs](Screenshots/Screenshot%202026-03-06%20095414.png)

### 8.2 — Network Tab Verification

Products page (`http://20.54.96.5`) — Network tab in DevTools confirms:

| Detail | Value |
|--------|-------|
| **Request URL** | `http://20.54.96.5/api/products?page=1&limit=12` |
| **Request Method** | GET |
| **Status Code** | 304 Not Modified |
| **Remote Address** | 20.54.96.5:80 |
| **10 products found** | ✅ |

![Step 8.2 — Network tab showing API calls via AG](Screenshots/Screenshot%202026-03-06%20095911.png)

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| **Three-Tier Architecture** | Frontend (presentation) → Backend (API/logic) → Database (data storage) |
| **Application Gateway** | Layer 7 load balancer with path-based routing — routes `/api/*` to backend, everything else to frontend |
| **SQL Firewall (Private)** | Only Backend VM IP allowed — no public internet access to the database |
| **CORS Configuration** | Backend must explicitly allow the origin (AG IP) of the frontend |
| **NSG Rules** | Port 3000 open on VM1 (frontend), port 3001 on VM2 (backend) |
| **Path-Based Routing** | AG uses URL path rules to direct traffic to different backend pools |
| **Backend Pools** | Separate pools for frontend (port 3000) and backend (port 3001) |
| **Health Probes** | AG sends `/health` requests to monitor backend availability |

### Troubleshooting Tips

| Issue | Solution |
|-------|----------|
| **CORS error** | Update `CORS_ORIGIN` in backend `.env` to match the AG public IP |
| **API not reachable** | Check NSG allows port 3001 on VM2 and AG health probe is passing |
| **Products not loading** | Verify `REACT_APP_API_URL` in frontend points to AG IP `/api` |
| **Database connection fails** | Check SQL firewall has Backend VM IP whitelisted |
| **502 Bad Gateway** | Ensure backend app is running and the correct port is in backend HTTP settings |
| **Node version warning** | Some packages require Node ≥20; v18.19.1 still works but shows warnings |
