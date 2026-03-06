# Lab 2 — Provision an Azure SQL Database and Connect via Azure Data Studio

> **Azure SQL Database** is a fully managed, serverless relational database service built on SQL Server. It handles patching, backups, and scaling automatically, so you can focus on application development.

In this lab, an Azure SQL Database was provisioned with the **AdventureWorksLT** sample dataset, a firewall rule was configured, and the database was connected via **Azure Data Studio**.

---

## 📌 Step 1 — Create a Resource Group

Navigate to **Resource groups** → **Create**:

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group name** | `rg-sql-lab-sakit` |
| **Region** | (Europe) North Europe |

![Step 1 — Create resource group](Screenshot%202026-03-05%20114649.png)

---

## 📌 Step 2 — Create the SQL Database

Navigate to **Azure SQL** → **SQL databases** → **Create** → **SQL database**:

![Step 2 — Azure SQL databases page](Screenshot%202026-03-05%20114746.png)

### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | `rg-sql-lab-sakit` |
| **Database name** | `devops-sqldb-sakit` |
| **Server** | (New) `devops-sql-server-sakit` |
| **Elastic pool** | No |
| **Workload environment** | Development |
| **Compute + storage** | General Purpose – Serverless (Gen5, 1 vCore, 32 GB storage) |
| **Backup storage redundancy** | Locally-redundant backup storage |

![Step 2 — Basics tab (database name, server creation)](Screenshot%202026-03-05%20114925.png)

### Create SQL Server

| Setting | Value |
|---------|-------|
| **Server name** | `devops-sql-server-sakit.database.windows.net` |
| **Location** | (Europe) North Europe |
| **Authentication method** | Use SQL authentication |
| **Server admin login** | `mr-sakit` |
| **Password** | ●●●●●●●●●● |

![Step 2 — Create SQL Server](Screenshot%202026-03-05%20115133.png)

### Basics Tab (after server creation)

![Step 2 — Basics tab complete with server](Screenshot%202026-03-05%20115236.png)

### Networking Tab

| Setting | Value |
|---------|-------|
| **Connectivity method** | Public endpoint |
| **Allow Azure services** | No |
| **Add current client IP** | No |
| **Connection policy** | Default |
| **Minimum TLS version** | TLS 1.2 |

**Cost summary:**

| Metric | Value |
|--------|-------|
| **Tier** | General Purpose (GP_S_Gen5_1) |
| **Cost per GB** | $0.13 |
| **Max storage** | 41.6 GB |
| **Estimated storage cost/month** | $5.26 USD |
| **Compute cost/vCore second** | $0.000148 USD |

> **Note:** Serverless databases are billed based on vCore-seconds consumed, making them cost-effective for intermittent workloads.

![Step 2 — Networking tab](Screenshot%202026-03-05%20115430.png)

### Additional Settings Tab

| Setting | Value |
|---------|-------|
| **Use existing data** | **Sample** (AdventureWorksLT) |
| **Collation** | SQL_Latin1_General_CP1_CI_AS (default) |

> **AdventureWorksLT** is a sample database with tables like `Customer`, `Product`, `SalesOrderHeader`, etc. — great for learning SQL queries.

![Step 2 — Additional settings (sample data)](Screenshot%202026-03-05%20115538.png)

### Deployment Complete

![Step 2 — Deployment complete](Screenshot%202026-03-05%20115846.png)

---

## 📌 Step 3 — Database Overview

After deployment, the overview page shows:

| Property | Value |
|----------|-------|
| **Resource group** | rg-sql-lab-sakit |
| **Server name** | devops-sql-server-sakit.database.windows.net |
| **Status** | Online |
| **Location** | North Europe |
| **Pricing tier** | General Purpose – Serverless: Gen5, 1 vCore |
| **Auto-pause delay** | 1 hour |

![Step 3 — Database overview](Screenshot%202026-03-05%20115923.png)

---

## 📌 Step 4 — Configure Firewall Rule

Click **Set server firewall** on the database overview page → **Networking** → **Add a firewall rule**:

| Setting | Value |
|---------|-------|
| **Rule name** | `all_ip` |
| **Start IP** | `0.0.0.0` |
| **End IP** | `255.255.255.255` |

> **⚠️ Warning:** This rule allows access from **all IP addresses**. This is acceptable for lab/development purposes only. **Never use this in production!** Instead, whitelist specific IPs or use Private Endpoints.

Click **OK** → **Save**.

![Step 4 — Firewall rule (allow all IPs for lab)](Screenshot%202026-03-05%20120045.png)

---

## 📌 Step 5 — Connect via Azure Data Studio

### 5.1 — Open Azure Data Studio

![Step 5.1 — Azure Data Studio welcome page](Screenshot%202026-03-05%20122000.png)

### 5.2 — Create a New Connection

Click **Create a connection** → Fill in the connection details:

| Setting | Value |
|---------|-------|
| **Connection type** | Microsoft SQL Server |
| **Input type** | Parameters |
| **Server** | `devops-sql-server-sakit.database.windows.net` |
| **Authentication type** | SQL Login |
| **User name** | `mr-sakit` |
| **Password** | ●●●●●●●●●● |
| **Remember password** | ✅ |
| **Database** | `devops-sqldb-sakit` |
| **Encrypt** | Mandatory |
| **Trust server certificate** | False |
| **Server group** | \<Default\> |
| **Name (optional)** | `SakitDatabase` |

Click **Connect**.

![Step 5.2 — Connection dialog with SQL Login details](Screenshot%202026-03-05%20122430.png)

### 5.3 — Verify Connection

After connecting, both **Azure Portal Query editor** and **Azure Data Studio** show the AdventureWorksLT database structure:

**Tables (SalesLT schema):**

| Table | Schema |
|-------|--------|
| BuildVersion | dbo |
| ErrorLog | dbo |
| Address | SalesLT |
| Customer | SalesLT |
| CustomerAddress | SalesLT |
| Product | SalesLT |
| ProductCategory | SalesLT |
| ProductDescription | SalesLT |
| ProductModel | SalesLT |
| ProductModelProductDescription | SalesLT |
| SalesOrderDetail | SalesLT |
| SalesOrderHeader | SalesLT |

**Views:** vGetAllCategories, vProductAndDescription, vProductModelCatalogDescription

**Stored Procedures:** uspLogError, uspPrintError

![Step 5.3 — Connected — Tables and views visible in both Portal and ADS](Screenshot%202026-03-05%20122636.png)

---

## 📌 Step 6 — Clean Up

To avoid ongoing charges:

1. Navigate to **Resource groups** → `rg-sql-lab-sakit`
2. Click **Delete resource group** → confirm the name
3. This deletes the SQL Database, SQL Server, and all related resources

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| **Azure SQL Database** | Fully managed PaaS relational database based on SQL Server |
| **Logical SQL Server** | A management endpoint for one or more databases (not a VM) |
| **General Purpose Serverless** | Auto-scaling compute that pauses when idle — pay per vCore-second |
| **AdventureWorksLT** | Microsoft's sample database for learning — includes customers, products, and sales data |
| **Public Endpoint** | Allows internet connectivity; requires firewall rules for access control |
| **Firewall Rules** | IP-based access control at the server level |
| **SQL Authentication** | Username/password-based login (alternative: Microsoft Entra / Azure AD) |
| **Azure Data Studio** | Cross-platform tool for managing SQL databases with GUI and query editor |
| **Port 1433** | Default port for SQL Server connections — must be open on your network |
| **TLS 1.2** | Minimum encryption protocol for secure database connections |

### Troubleshooting Tips

| Issue | Solution |
|-------|----------|
| **Connection refused** | Check firewall rules — your IP must be whitelisted |
| **Login failed** | Verify username and password; username is just the login name, not an email |
| **Server not found** | Use the full server name: `server-name.database.windows.net` |
| **Port 1433 blocked** | Corporate firewalls may block this port — try a different network |
| **Deployment not finished** | Wait for "Your deployment is complete" before connecting |
