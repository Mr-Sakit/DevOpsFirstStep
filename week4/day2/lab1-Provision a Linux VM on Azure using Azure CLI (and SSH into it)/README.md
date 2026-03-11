# Lab 1 — Provision a Linux VM on Azure Using Azure CLI (and SSH into It)

In this lab, a Linux (Ubuntu) VM was provisioned on Azure entirely through Azure CLI in Cloud Shell. After the VM was created, an SSH connection was established, the OS was verified, and the resources were cleaned up.

---

## 📌 Part A — Set Variables

Environment variables were defined to keep subsequent commands clean and reusable.

```bash
RESOURCE_GROUP="rg-azure-cli-lab-sakit"
LOCATION="northeurope"
VM_NAME="cli-ubuntu-vm-sakit"
ADMIN_USERNAME="mr-sakit"
```

![Part A — Setting environment variables](Screenshots/Screenshot%202026-03-10%20111552.png)

---

## 📌 Part B — Create a Resource Group

A new resource group was created using the `az group create` command.

```bash
az group create --name $RESOURCE_GROUP --location $LOCATION
```

**Output:**

| Property | Value |
|----------|-------|
| **name** | `rg-azure-cli-lab-sakit` |
| **location** | `northeurope` |
| **provisioningState** | `Succeeded` |
| **type** | `Microsoft.Resources/resourceGroups` |

![Part B — Resource group created successfully](Screenshots/Screenshot%202026-03-10%20111552.png)

---

## 📌 Part C — Create a Linux VM

A Linux VM was provisioned using the `az vm create` command with Ubuntu 22.04 image and SSH key authentication.

```bash
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image Ubuntu2204 \
    --size Standard_D2s_v3 \
    --admin-username $ADMIN_USERNAME \
    --authentication-type ssh \
    --generate-ssh-keys
```

![Part C — VM creation command (Running)](Screenshots/Screenshot%202026-03-10%20112113.png)

**VM Creation Output:**

| Property | Value |
|----------|-------|
| **publicIpAddress** | `134.149.16.195` |
| **privateIpAddress** | `10.0.0.4` |
| **powerState** | `VM running` |
| **location** | `northeurope` |
| **macAddress** | `70-A8-A5-2D-61-E9` |
| **resourceGroup** | `rg-azure-cli-lab-sakit` |

![Part C — VM created successfully with output](Screenshots/Screenshot%202026-03-10%20112348.png)

---

## 📌 Part D — SSH into the VM

The public IP was retrieved programmatically, then used to establish an SSH connection.

```bash
PUBLIC_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)
echo "Your VM public IP is: $PUBLIC_IP"
```

```
Your VM public IP is: 134.149.16.195
```

```bash
ssh $ADMIN_USERNAME@$PUBLIC_IP
```

The SSH fingerprint was accepted and the connection was established successfully.

```
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.8.0-1044-azure x86_64)
```

![Part D — SSH connection to the VM](Screenshots/Screenshot%202026-03-10%20112643.png)

---

## 📌 Part E — Verify the OS

Inside the VM, the operating system details were verified using `lsb_release` and `uname`.

```bash
lsb_release -a || cat /etc/os-release
```

| Property | Value |
|----------|-------|
| **Distributor ID** | Ubuntu |
| **Description** | Ubuntu 22.04.5 LTS |
| **Release** | 22.04 |
| **Codename** | jammy |

```bash
uname -a
```

```
Linux cli-ubuntu-vm-sakit 6.8.0-1044-azure #50~22.04.1-Ubuntu SMP Wed Dec  3 15:13:22 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
```

![Part E — OS verification](Screenshots/Screenshot%202026-03-10%20112847.png)

---

## 📌 Part F — Clean Up Resources

After exiting the SSH session, the resource group (and all its resources) was deleted to avoid ongoing charges.

```bash
exit
```

```bash
az group delete --name $RESOURCE_GROUP --yes --no-wait
```

Verified that the resource group was in a **Deleting** state:

```bash
az group show --name $RESOURCE_GROUP
```

| Property | Value |
|----------|-------|
| **name** | `rg-azure-cli-lab-sakit` |
| **provisioningState** | `Deleting` |

![Part F — Resource group deletion](Screenshots/Screenshot%202026-03-10%20112853.png)

---

## 🧠 Key Takeaways

| Topic | Details |
|-------|---------|
| **Azure CLI** | Command-line tool for managing Azure resources (alternative to Portal) |
| **Cloud Shell** | Browser-based shell with Azure CLI pre-installed |
| **az group create** | Creates a resource group to logically contain resources |
| **az vm create** | Provisions a virtual machine with specified image, size, and auth |
| **--generate-ssh-keys** | Auto-generates SSH key pair for authentication |
| **az vm show -d** | Retrieves detailed VM info including public IP |
| **SSH** | Secure Shell protocol for connecting to Linux VMs (port 22) |
| **az group delete** | Deletes resource group and all contained resources |
| **--no-wait** | Returns immediately without waiting for the operation to complete |
| **Cost Control** | Always delete unused resource groups to avoid charges |
