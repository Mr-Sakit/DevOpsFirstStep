# Lab 4: Provision an Azure Container Application and Deploy a Node Application

## 📋 Overview

This lab demonstrates how to deploy a containerized **Node.js** application to **Azure Container Apps** — a fully managed serverless container platform. The workflow includes creating an Azure Container Registry (ACR), pushing a Docker image to the registry, provisioning an Azure Container App environment, and deploying the application with public ingress. Azure Container Apps is ideal for running microservices, APIs, and background processing without managing infrastructure.

---

## 🎯 Objectives

- Create an Azure Container Registry (ACR)
- Build and push a Docker image to ACR
- Create an Azure Container Apps environment
- Deploy the containerized application with public ingress
- Verify the deployed application is accessible via FQDN
- Understand Azure Container Apps architecture

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Azure Account** | Active subscription (IDDAB2G) |
| **Azure CLI** | Installed with Container Apps extension |
| **Docker** | Installed and running |
| **Node.js App** | Containerized application with Dockerfile |

---

## 📝 Lab Steps

### Step 1: Create an Azure Container Registry (ACR)

An Azure Container Registry is a private Docker registry for storing and managing container images:

![ACR Creation](Screenshots/Screenshot%202026-03-16%20114217.png)

**ACR Configuration:**

| Setting | Value |
|---|---|
| Registry name | `sakitregistry` |
| Resource group | `rg-container-app-sakit` |
| Location | North Europe |
| SKU | Basic |

> **What is ACR?** Azure Container Registry is a managed Docker registry service for building, storing, and serving container images. The Basic SKU is cost-effective for development and learning scenarios.

---

### Step 2: Build and Push the Docker Image to ACR

Log in to the registry and push the image:

```bash
# Login to ACR
az acr login --name sakitregistry

# Tag the image for ACR
docker tag sample-nodejs-app sakitregistry.azurecr.io/sample-nodejs-app:v1

# Push the image to ACR
docker push sakitregistry.azurecr.io/sample-nodejs-app:v1
```

![Push to ACR](Screenshots/Screenshot%202026-03-16%20115454.png)

Verify the image is in the registry:

```bash
az acr repository list --name sakitregistry --output table
```

---

### Step 3: Create a Container Apps Environment

The Container Apps environment provides the managed infrastructure for running container apps:

![Container App Environment](Screenshots/Screenshot%202026-03-16%20122457.png)

```bash
# Create a Container Apps environment
az containerapp env create \
  --name sakit-container-env \
  --resource-group rg-container-app-sakit \
  --location northeurope
```

> **Container Apps Environment** is a secure boundary around a group of container apps. Apps in the same environment share the same virtual network, logging, and Dapr configuration.

---

### Step 4: Deploy the Container Application

Create the Container App with the image from ACR:

![Deploy Container App](Screenshots/Screenshot%202026-03-16%20124329.png)

```bash
az containerapp create \
  --name nodejs-app-sakit \
  --resource-group rg-container-app-sakit \
  --environment sakit-container-env \
  --image sakitregistry.azurecr.io/sample-nodejs-app:v1 \
  --target-port 3000 \
  --ingress external \
  --registry-server sakitregistry.azurecr.io \
  --min-replicas 1 \
  --max-replicas 3
```

**Deployment Parameters:**

| Parameter | Purpose |
|---|---|
| `--target-port 3000` | The port your app listens on |
| `--ingress external` | Enables public HTTP access |
| `--min-replicas 1` | Minimum number of running instances |
| `--max-replicas 3` | Maximum instances for auto-scaling |

---

### Step 5: Configure Ingress and Access the Application

After deployment, the Container App receives a public **FQDN** (Fully Qualified Domain Name):

![Application URL](Screenshots/Screenshot%202026-03-16%20124441.png)

The application is accessible at:

```
https://nodejs-app-sakit.<region>.azurecontainerapps.io
```

---

### Step 6: Verify the Deployed Application

Navigate to the FQDN in a web browser to verify the application is running:

![Application Running](Screenshots/Screenshot%202026-03-16%20124503.png)

✅ **Result:** The Node.js application is successfully deployed and accessible via Azure Container Apps with HTTPS enabled automatically.

---

### Step 7: Monitor and Manage the Application

The Azure Portal provides a comprehensive overview of the container app:

![Container App Overview](Screenshots/Screenshot%202026-03-16%20130331.png)

Key monitoring features:
- **Revision management** — Track and manage different versions
- **Metrics** — CPU, memory, and request metrics
- **Log stream** — Real-time application logs
- **Scale and replicas** — View auto-scaling behavior

---

### Step 8: Cleanup

To avoid ongoing charges, clean up the resources:

```bash
# Delete the resource group and all contained resources
az group delete --name rg-container-app-sakit --yes --no-wait
```

![Resource Cleanup](Screenshots/Screenshot%202026-03-16%20130447.png)

---

## 🏗️ Architecture Diagram

```
┌─────────────────┐     ┌──────────────────────┐     ┌────────────────────────┐
│   Docker Build  │────▶│  Azure Container      │────▶│  Azure Container Apps  │
│   (Local)       │     │  Registry (ACR)       │     │  Environment           │
│                 │     │  sakitregistry         │     │                        │
│  Dockerfile     │     │  .azurecr.io          │     │  ┌──────────────────┐ │
│  + Source Code  │     │                        │     │  │ nodejs-app-sakit │ │
│                 │     │  sample-nodejs-app:v1  │     │  │ Port: 3000       │ │
└─────────────────┘     └──────────────────────┘     │  │ Ingress: External│ │
                                                      │  └──────────────────┘ │
                                                      └────────────────────────┘
                                                              │
                                                              ▼
                                                      Public FQDN (HTTPS)
```

---

## 📊 Summary

| Task | Status |
|---|---|
| Create Azure Container Registry (ACR) | ✅ |
| Push Docker image to ACR | ✅ |
| Create Container Apps environment | ✅ |
| Deploy Container App with external ingress | ✅ |
| Verify application via FQDN | ✅ |
| Monitor and manage the application | ✅ |
| Cleanup resources | ✅ |

---

## 💡 Key Takeaways

1. **Azure Container Apps** is a serverless platform that abstracts away infrastructure management
2. **ACR** provides secure, private storage for Docker images within the Azure ecosystem
3. **External ingress** automatically provisions HTTPS endpoints with managed TLS certificates
4. **Auto-scaling** (min/max replicas) allows the app to handle variable workloads efficiently
5. Container Apps supports **revision management** for blue/green deployments and rollbacks
6. Always **delete resource groups** after lab exercises to prevent unexpected Azure charges
