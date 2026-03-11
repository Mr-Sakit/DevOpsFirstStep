# Lab 2 — Provision Azure Blob Storage with Azure CLI

In this lab, Azure Blob Storage was provisioned entirely through Azure CLI. A storage account and container were created, a blob was uploaded/downloaded, a SAS token was generated for read-only sharing, and all resources were cleaned up.

---

## 📌 Part A — Set Variables & Create Resource Group

Environment variables were defined, then a resource group was created.

```bash
RESOURCE_GROUP="rg-blob-cli-sakit"
LOCATION="northeurope"
SA_NAME="sakitsa$RANDOM$RANDOM"
CONTAINER="sample-container"
BLOB_NAME="sakit.txt"
```

```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

| Property | Value |
|----------|-------|
| **name** | `rg-blob-cli-sakit` |
| **location** | `northeurope` |
| **provisioningState** | `Succeeded` |

![Part A — Variables and resource group creation](Screenshots/Screenshot%202026-03-11%20063559.png)

---

## 📌 Part B — Create a Storage Account

A general-purpose v2 storage account was created with Standard LRS redundancy and public blob access disabled.

```bash
az storage account create \
    --name $SA_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --sku Standard_LRS \
    --kind StorageV2 \
    --allow-blob-public-access false
```

![Part B — Storage account creation (in progress)](Screenshots/Screenshot%202026-03-11%20063559.png)

---

## 📌 Part C — Create a Container & Upload a Blob

### Create Container

```bash
az storage container create \
    --name $CONTAINER \
    --account-name $SA_NAME \
    --auth-mode login
```

```json
{
  "created": true
}
```

### Upload Blob (First Attempt — Permission Error)

A text file was created and an upload was attempted using `--auth-mode login`:

```bash
echo "Hello from Azure Blob Storage 🔥" > $BLOB_NAME

az storage blob upload \
    --account-name $SA_NAME \
    --container-name $CONTAINER \
    --name $BLOB_NAME \
    --file $BLOB_NAME \
    --auth-mode login
```

> ⚠️ **Error:** "You do not have the required permissions to perform this operation." — A data-plane RBAC role was needed.

![Part C — Container created, blob upload permission error](Screenshots/Screenshot%202026-03-11%20071046.png)

### Fix — Assign Storage Blob Data Contributor Role

```bash
USER_ID=$(az ad signed-in-user show --query id -o tsv)
SCOPE=$(az storage account show --name $SA_NAME --query id -o tsv)

az role assignment create \
    --role "Storage Blob Data Contributor" \
    --assignee $USER_ID \
    --scope $SCOPE
```

### Upload Blob (Success)

After the role assignment, the blob was uploaded successfully:

```bash
echo "Hello from Azure Blob Storage 🔥" > $BLOB_NAME

az storage blob upload \
    --account-name $SA_NAME \
    --container-name $CONTAINER \
    --name $BLOB_NAME \
    --file $BLOB_NAME \
    --auth-mode login
```

```
Finished[#############################################]  100.0000%
```

| Property | Value |
|----------|-------|
| **request_server_encrypted** | `true` |
| **etag** | `"0x8DE7F199FD9E9FD"` |
| **lastModified** | `2026-03-11T02:55:16+00:00` |

![Part C — Role assignment and successful blob upload](Screenshots/Screenshot%202026-03-11%20071108.png)

---

## 📌 Part D — List, Show & Download the Blob

### List Blobs

```bash
az storage blob list \
    --account-name $SA_NAME \
    --container-name $CONTAINER \
    --auth-mode login \
    --output table
```

| Name | Blob Type | Blob Tier | Length | Content Type | Last Modified |
|------|-----------|-----------|--------|--------------|---------------|
| sakit.txt | BlockBlob | Hot | 35 | text/plain | 2026-03-11T02:55:16+00:00 |

### Show Blob Details

```bash
az storage blob show \
    --account-name $SA_NAME \
    --container-name $CONTAINER \
    --name $BLOB_NAME \
    --auth-mode login \
    --output table
```

### Download Blob

```bash
az storage blob download \
    --account-name $SA_NAME \
    --container-name $CONTAINER \
    --name $BLOB_NAME \
    --file downloaded-$BLOB_NAME \
    --auth-mode login
```

```
Finished[#############################################]  100.0000%
```

![Part D — Blob list, show, and download](Screenshots/Screenshot%202026-03-11%20071129.png)

### Verify Content

```bash
echo "Original:" && cat $BLOB_NAME
echo "Downloaded:" && cat downloaded-$BLOB_NAME
```

```
Original:
Hello from Azure Blob Storage 🔥
Downloaded:
Hello from Azure Blob Storage 🔥
```

✅ Both files match — the upload/download cycle is verified.

![Part D — Content verification](Screenshots/Screenshot%202026-03-11%20071156.png)

---

## 📌 Part E — Generate a SAS Token & Share the Blob

### Set Expiry (1 hour)

```bash
EXPIRY=$(date -u -d "1 hour" '+%Y-%m-%dT%H:%MZ')
```

### Generate SAS Token (First Attempt — Error)

```bash
SAS_TOKEN=$(az storage blob generate-sas \
    --account-name $SA_NAME \
    --container-name $CONTAINER \
    --name $BLOB_NAME \
    --permissions r \
    --expiry $EXPIRY \
    --https-only \
    --auth-mode login \
    --output tsv)
```

> ⚠️ **Error:** "incorrect usage: specify `--as-user` when `--auth-mode login` is used to get user delegation key."

### Generate SAS Token (Fixed — with `--as-user`)

```bash
SAS_TOKEN=$(az storage blob generate-sas \
    --account-name $SA_NAME \
    --container-name $CONTAINER \
    --name $BLOB_NAME \
    --permissions r \
    --expiry $EXPIRY \
    --https-only \
    --auth-mode login \
    --as-user \
    --output tsv)
```

![Part E — SAS token generation](Screenshots/Screenshot%202026-03-11%20071216.png)

### Build and Share the SAS URL

```bash
SAS_URL="https://${SA_NAME}.blob.core.windows.net/${CONTAINER}/${BLOB_NAME}?${SAS_TOKEN}"
echo "$SAS_URL"
```

```
Shareable (read-only) SAS URL:
https://sakitsa1829126716.blob.core.windows.net/sample-container/sakit.txt?se=2026-03-11T03%3A...
```

![Part E — SAS URL generated](Screenshots/Screenshot%202026-03-11%20071235.png)

### Verify in Browser

The SAS URL was opened in a browser and the blob content was displayed successfully:

```
Hello from Azure Blob Storage 🔥
```

![Part E — Blob accessed via SAS URL in browser](Screenshots/Screenshot%202026-03-11%20071338.png)

---

## 📌 Part F — Clean Up Resources

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

Verified the resource group is being deleted:

```bash
az group show --name $RESOURCE_GROUP
```

| Property | Value |
|----------|-------|
| **name** | `rg-blob-cli-sakit` |
| **provisioningState** | `Deleting` |

![Part F — Resource group deletion](Screenshots/Screenshot%202026-03-11%20071457.png)

---

## 🧠 Key Takeaways

| Topic | Details |
|-------|---------|
| **az storage account create** | Creates a storage account (StorageV2, Standard_LRS) |
| **--allow-blob-public-access false** | Disables anonymous public read access to blobs |
| **az storage container create** | Creates a blob container inside a storage account |
| **--auth-mode login** | Authenticates using Azure AD (Entra ID) instead of account keys |
| **RBAC Role** | `Storage Blob Data Contributor` is required for data-plane operations via Azure AD |
| **az storage blob upload/download** | Uploads and downloads blobs from a container |
| **SAS Token** | Shared Access Signature — provides time-limited, scoped access to a blob |
| **--as-user** | Required with `--auth-mode login` to generate a user delegation SAS |
| **--https-only** | Restricts SAS token usage to HTTPS connections only |
| **Cost Control** | Always delete resource groups after lab use to avoid charges |
