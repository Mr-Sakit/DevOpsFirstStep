# Lab 1 — Provision Azure Blob Storage and Connect via Azure Storage Explorer

> **Azure Blob Storage** is a cloud object storage service for storing large amounts of unstructured data (text, images, videos, backups, etc.). Data is organized into **Storage Accounts** → **Containers** → **Blobs**.

In this lab, an Azure Storage Account was created, a blob container was provisioned, a file was uploaded, and the container was connected via **Azure Storage Explorer** using a SAS token.

---

## 📌 Step 1 — Create an Azure Storage Account

Navigate to **Storage center** → **Blob Storage** → Click **+ Create**.

![Step 1 — Storage center overview](Screenshots/Screenshot%202026-03-05%20104557.png)

### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource group** | (New) `rg-storage-lab-sakit` |
| **Storage account name** | `devopsstorageaccountsakit` |
| **Region** | (Europe) North Europe |
| **Performance** | Standard (general-purpose v2) |
| **Redundancy** | Geo-redundant storage (GRS) |
| **Read access to data in case of regional unavailability** | ✅ (RA-GRS) |

> **Note:** The storage account name must be **globally unique**, lowercase, and can only include letters and numbers (3–24 characters).

![Step 1 — Basics tab](Screenshots/Screenshot%202026-03-05%20104948.png)

### Advanced Tab

| Setting | Value |
|---------|-------|
| **Require secure transfer (REST API)** | ✅ |
| **Allow anonymous access on containers** | ❌ |
| **Enable storage account key access** | ✅ |
| **Minimum TLS version** | Version 1.2 |
| **Hierarchical namespace (Data Lake)** | ❌ |
| **Access tier** | **Hot** (frequently accessed data) |
| **Enable SFTP** | ❌ |
| **Enable NFS v3** | ❌ |

> **Access Tier Explanation:**
> - **Hot** — Optimized for frequently accessed data (higher storage cost, lower access cost)
> - **Cool** — For infrequently accessed data (lower storage cost, higher access cost)
> - **Cold/Archive** — For rarely accessed data (lowest storage cost, highest access cost)

![Step 1 — Advanced tab (security & access tier)](Screenshots/Screenshot%202026-03-05%20105126.png)

### Review + Create

| Section | Setting | Value |
|---------|---------|-------|
| **Basics** | Storage account name | `devopsstorageaccountsakit` |
| | Location | North Europe |
| | Performance | Standard |
| | Replication | RA-GRS |
| **Advanced** | Access tier | Hot |
| | Blob anonymous access | Disabled |
| **Security** | Secure transfer | Enabled |
| | Min TLS version | 1.2 |
| **Networking** | Public network access | Enabled from all networks |

![Step 1 — Review + create](Screenshots/Screenshot%202026-03-05%20105206.png)

### Storage Account Overview

After deployment, the overview page shows all configured services and settings:

![Step 1 — Storage account overview](Screenshots/Screenshot%202026-03-05%20105257.png)

---

## 📌 Step 2 — Create a Blob Container

In the storage account → **Data storage** → **Containers** → Click **+ Container**:

| Setting | Value |
|---------|-------|
| **Name** | `devops-container-lab-sakit` |
| **Public access level** | Private (no anonymous access) |

> **Container naming rules:** All lowercase, must start with a letter or number, only letters/numbers/hyphens allowed, 3–63 characters.

---

## 📌 Step 3 — Upload a Blob (File)

Open the container → Click **Upload** → Select a file:

| Setting | Value |
|---------|-------|
| **File** | `sakit.txt` |
| **Blob type** | Block blob (auto-detected) |
| **Access tier** | Hot (Inferred from account default) |

![Step 3 — Upload blob dialog](Screenshots/Screenshot%202026-03-05%20110205.png)

### Verify Upload

The uploaded file appears in the container:

| Name | Last Modified | Access Tier | Blob Type | Size | Lease State |
|------|---------------|-------------|-----------|------|-------------|
| `sakit.txt` | 05.03.2026 11:02:06 | Hot (Inferred) | Block blob | 0 | Available |

![Step 3 — Blob listed in container](Screenshots/Screenshot%202026-03-05%20111716.png)

---

## 📌 Step 4 — Generate a SAS Token

To connect via Azure Storage Explorer, generate a **Shared Access Signature (SAS)**:

Go to container → **Settings** → **Shared access tokens**:

| Setting | Value |
|---------|-------|
| **Signing method** | Account key |
| **Signing key** | Key 1 |
| **Permissions** | Read, Add, Create, Write, Delete, List (6 selected) |
| **Allowed protocols** | HTTPS only |

Click **Generate SAS token and URL**.

![Step 4 — SAS token configuration](Screenshots/Screenshot%202026-03-05%20113053.png)

### Generated SAS Token and URL

The portal generates:
- **Blob SAS token** — A query string with signed permissions, expiry, and signature
- **Blob SAS URL** — Full URL to the container with SAS token appended

```
https://devopsstorageaccountsakit.blob.core.windows.net/devops-container-lab-sakit?sp=racwdl&st=2026-03-05T07:14:51Z&se=2026-03-05T15:29:51Z&spr=https&sv=2024-11-04&sr=c&sig=...
```

> **⚠️ Important:** SAS tokens are time-limited and grant access without needing account keys. Never share them publicly.

![Step 4 — Generated SAS token and URL](Screenshots/Screenshot%202026-03-05%20113126.png)

---

## 📌 Step 5 — Connect via Azure Storage Explorer

### 5.1 — Sign In to Azure

Open **Microsoft Azure Storage Explorer** → Sign in with your Azure credentials:

![Step 5.1 — Azure Storage Explorer sign in](Screenshots/Screenshot%202026-03-05%20113148.png)

### 5.2 — Open Connect Dialog

Click the **Connect (plug icon)** → Select **Blob container or directory**:

![Step 5.2 — Select resource type](Screenshots/Screenshot%202026-03-05%20113211.png)

### 5.3 — Select Connection Method

Choose **Shared access signature URL (SAS)**:

![Step 5.3 — Select SAS connection method](Screenshots/Screenshot%202026-03-05%20113239.png)

### 5.4 — Enter SAS URL

Paste the **Blob SAS URL** generated in Step 4:

| Setting | Value |
|---------|-------|
| **Display name** | `devops-container-lab-sakit` |
| **Blob container or directory SAS URL** | (paste the full SAS URL) |

![Step 5.4 — Enter SAS URL](Screenshots/Screenshot%202026-03-05%20113330.png)

### 5.5 — Review and Connect

Summary of connection settings:

| Property | Value |
|----------|-------|
| **Display name** | devops-container-lab-sakit |
| **Resource name** | devops-container-lab-sakit |
| **Blob endpoint** | https://devopsstorageaccountsakit.blob.core.windows.net |
| **Resource type** | Container |
| **Permissions** | Read, Add, Create, Write, Delete, List |

Click **Connect**.

![Step 5.5 — Connection summary](Screenshots/Screenshot%202026-03-05%20113346.png)

### 5.6 — Verify in Storage Explorer

The container is now accessible in Storage Explorer. The uploaded blob `sakit.txt` is visible:

| Name | Access Tier | Last Modified | Blob Type | Content Type |
|------|-------------|---------------|-----------|-------------|
| `sakit.txt` | Hot (inferred) | 3/5/2026 11:02 AM | Block Blob | text/plain |

You can now perform **CRUD operations** (Upload, Download, Delete, Copy, Paste, etc.) directly from Storage Explorer — changes sync with the Azure Portal.

![Step 5.6 — Connected to blob container in Storage Explorer](Screenshots/Screenshot%202026-03-05%20113438.png)

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| **Storage Account** | Top-level container for all Azure Storage services (Blob, File, Queue, Table) |
| **Blob Container** | Logical grouping of blobs within a storage account (like a folder) |
| **Blob** | Any file stored in Azure Blob Storage (Block, Append, or Page blob) |
| **Block Blob** | Default type for most files — optimized for upload/download of large files |
| **Access Tier (Hot)** | Best for frequently accessed data — lower access cost, higher storage cost |
| **RA-GRS** | Read-Access Geo-Redundant Storage — data replicated to a secondary region with read access |
| **SAS Token** | Shared Access Signature — grants limited, time-bound access to storage resources |
| **Storage Explorer** | Desktop app for managing Azure Storage via GUI — supports SAS, OAuth, and key-based auth |
| **Private Access** | Container is not publicly accessible; requires authentication (key, SAS, or Azure AD) |
