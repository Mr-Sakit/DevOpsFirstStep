# Lab 2 — Provisioning a Basic Azure Web App via Azure Portal

In this lab, an Azure App Service Web App was provisioned using the Azure Portal, the default landing page was verified, and a sample Node.js application was deployed via GitHub Actions CI/CD pipeline.

---

## 📌 Step 1 — Log in to the Azure Portal

Navigate to [https://portal.azure.com](https://portal.azure.com) and sign in with your Azure account.

---

## 📌 Step 2 — Navigate to App Services

1. On the Azure Portal dashboard, click **App Services**
2. Click **+ Create** → select **Web App**

![Step 2 — App Services → Create Web App](Screenshot%202026-03-03%20102907.png)

---

## 📌 Step 3 — Create a New Web App (Basic Settings)

### Basics Tab

| Setting | Value |
|---------|-------|
| **Subscription** | IDDAB2G |
| **Resource Group** | (New) `SakitWebAppRG` |
| **Name** | `sakit-webapp` |
| **Publish** | Code |
| **Runtime stack** | Node 20 LTS |
| **Operating System** | Linux |
| **Region** | Austria East |
| **Linux Plan** | (New) ASP-SakitWebAppRG-98bc |
| **Pricing plan** | Free F1 (Shared infrastructure) |

> **Note:** The web app name must be globally unique. The URL will be: `https://sakit-webapp-ava2hmbqczckgvd7.austriaeast-01.azurewebsites.net`

![Step 3 — Create Web App (Basics tab)](Screenshot%202026-03-03%20103650.png)

---

## 📌 Step 4 — Review and Create

The Review + create page summarizes all settings:

| Detail | Value |
|--------|-------|
| **Resource Group** | SakitWebAppRG |
| **Name** | sakit-webapp |
| **Secure unique default hostname** | Enabled |
| **Publish** | Code |
| **Runtime stack** | Node 20 LTS |
| **App Service Plan** | ASP-SakitWebAppRG-98bc |
| **Operating System** | Linux |
| **Region** | Austria East |
| **SKU** | Free |
| **ACU** | Shared infrastructure |
| **Memory** | 1 GB memory |
| **Estimated price** | Free |

Click **Create** to begin provisioning.

![Step 4 — Review + create](Screenshot%202026-03-03%20103753.png)

### Deployment Complete

Deployment completed successfully. Click **Go to resource**.

![Step 4 — Deployment complete](Screenshot%202026-03-03%20104032.png)

---

## 📌 Step 5 — Verify the Web App Deployment

### Web App Overview

| Property | Value |
|----------|-------|
| **Resource group** | SakitWebAppRG |
| **Status** | Running |
| **Location** | Austria East |
| **Default domain** | `sakit-webapp-ava2hmbqczckgvd7.austriaeast-01.azurewebsites.net` |
| **App Service Plan** | ASP-SakitWebAppRG-98bc (F1: 1) |
| **Operating System** | Linux |
| **Runtime Stack** | Node - 20-lts |
| **Runtime status** | Healthy |
| **Publishing model** | Code |
| **Virtual IP address** | 68.210.171.1 |

![Step 5 — Web App Overview page](Screenshot%202026-03-03%20104645.png)

### Default Landing Page

Click **Browse** to open the web app URL. The Azure default welcome page was displayed — confirming the web app is running.

> **"Your web app is running and waiting for your content"**

![Step 5 — Default Azure Web App page](Screenshot%202026-03-03%20104656.png)

---

## 📌 Step 6 — Deploy a Node.js Application

### 6.1 — Fork the Sample Repository

1. Navigate to the sample Node.js application on GitHub: [saurabhd2106/sample-nodejs-app-ih](https://github.com/saurabhd2106/sample-nodejs-app-ih)
2. Click **Fork** to create your own copy

| Setting | Value |
|---------|-------|
| **Owner** | Mr-Sakit |
| **Repository name** | `sample-nodejs-app-ih` |
| **Branch** | Copy the `main` branch only |

![Step 6.1 — Fork the repository](Screenshot%202026-03-03%20105113.png)

![Step 6.1 — Create a new fork](Screenshot%202026-03-03%20105146.png)

### 6.2 — Configure Deployment Center

Navigate to **Deployment** → **Deployment Center** in the Web App and configure GitHub as the source.

| Setting | Value |
|---------|-------|
| **Source** | GitHub |
| **Signed in as** | Mr-Sakit |
| **Organization** | Mr-Sakit |
| **Repository** | `sample-nodejs-app-ih` |
| **Branch** | `main` |
| **Workflow option** | Add a workflow: `main_sakit-webapp.yml` |
| **Runtime stack** | Node |
| **Runtime version** | 20-lts |
| **Authentication type** | User-assigned identity |
| **Subscription** | IDDAB2G |
| **Identity** | (New) oidc-msi-b38c |

![Step 6.2 — Deployment Center configuration](Screenshot%202026-03-03%20105902.png)

### 6.3 — Verify GitHub Actions Workflow

Save the settings. Navigate to the forked GitHub repository → **Actions** tab. The CI/CD workflow automatically runs.

| Workflow Run | Status | Duration |
|--|--|--|
| Update GitHub Actions workflow for A... | ✅ Success | 1m 23s |
| Add or update the Azure App Service ... | ❌ Failed | 13s |

> The first deployment attempt failed, but a subsequent workflow update resolved the issue.

![Step 6.3 — GitHub Actions workflow runs](Screenshot%202026-03-03%20112235.png)

### 6.4 — Verify Deployed Application

After the successful deployment, the Deployment Center shows the connected GitHub source.

| Property | Value |
|----------|-------|
| **Source** | GitHub |
| **Organization** | Mr-Sakit |
| **Repository** | sample-nodejs-app-ih |
| **Branch** | main |
| **Build provider** | GitHub Actions |
| **Runtime stack** | Node |
| **Version** | 20-lts |

![Step 6.4 — Deployment Center (connected)](Screenshot%202026-03-03%20112246.png)

Navigate to the URL and refresh — the **DevOps Bootcamp Showcase** application is now live! 🎉

![Step 6.4 — Deployed Node.js application](Screenshot%202026-03-03%20112313.png)

---

## 🧠 Key Takeaways

| Topic | Details |
|-------|---------|
| **Azure App Service** | PaaS for hosting web apps without managing infrastructure |
| **Runtime Stack** | Node.js 20 LTS on Linux |
| **Pricing Tier** | Free F1 — shared infrastructure, no cost |
| **Deployment Method** | GitHub Actions CI/CD pipeline |
| **Workflow** | Automatically triggered on push to `main` branch |
| **Default URL** | `https://<app-name>.azurewebsites.net` |
| **Resource Group** | Logical container for grouping Azure resources |
| **Clean Up** | Always delete resource group to avoid charges |
