# Lab 1 - Hosting a Simple HTML Page with Apache Server

In this lab, Apache HTTP Server was installed on an Azure Linux VM (Ubuntu 22.04), an inbound security rule was added for HTTP port 80, a custom HTML page was deployed, and the web server was verified through the browser, `curl`, and log inspection.

---

## 📌 Step 1 — Adding an Inbound Security Rule for HTTP (Port 80)

Before the web server can be accessed from the internet, an inbound port rule must be added to the VM's Network Security Group (NSG).

**Navigation:** VM (`rg-lab-azurevm-sakit`) → **Networking** → **Network settings** → **+ Create port rule** → **Inbound port rule**

**Rule Configuration:**

| Setting | Value |
|---------|-------|
| Source | Any |
| Source port ranges | * |
| Destination | Any |
| Service | Custom |
| Destination port ranges | **80** |
| Protocol | Any |
| Action | **Allow** |
| Priority | 310 |
| Name | **ApacheLabServer** |

**Result:** A new inbound security rule `ApacheLabServer` was added to the NSG `rg-lab-azurevm-sakit-nsg`, allowing HTTP traffic on port 80.

![Step 1a — Network settings with existing rules and Create port rule](Screenshot%202026-02-26%20092557.png)
![Step 1b — Add inbound security rule form](Screenshot%202026-02-26%20092806.png)

---

## 📌 Step 2 — Updating Packages and Installing Apache2

SSH into the VM and update the package list, then install Apache2.

**Commands executed:**
```bash
sudo apt update                    # Update package lists
sudo apt install -y apache2        # Install Apache2 web server
```

**Result:** Package lists were fetched from `azure.archive.ubuntu.com`. Apache2 and its dependencies (`apache2-bin`, `apache2-data`, `apache2-utils`, `libapr1`, etc.) were installed successfully.

![Step 2a — sudo apt update](Screenshot%202026-02-26%20101439.png)
![Step 2b — sudo apt install -y apache2](Screenshot%202026-02-26%20101457.png)

---

## 📌 Step 3 — Verifying Apache Status

After installation, the Apache service status was checked.

```bash
sudo systemctl status apache2
```

**Result:** Apache was **active (running)** since `2026-02-26 06:10:52 UTC`. The service was loaded from `/lib/systemd/system/apache2.service` and enabled by default. Three worker processes were running under PID 2281.

![Step 3 — Apache status: active (running)](Screenshot%202026-02-26%20101518.png)

---

## 📌 Step 4 — Stopping, Starting, and Deploying a Custom HTML Page

Apache was stopped, restarted, and a custom HTML page was deployed to the default web root.

**Commands executed:**
```bash
sudo systemctl stop apache2          # Stop Apache
sudo systemctl status apache2        # Verify: inactive (dead)
sudo systemctl start apache2         # Start Apache again
sudo systemctl status apache2        # Verify: active (running)
```

### Creating the Custom HTML Page

```bash
echo '<!doctype html>
<html>
  <head><meta charset="utf-8"><title>My First Apache Page</title></head>
  <body style="font-family: sans-serif;">
    <h1>Hello from Apache on Ubuntu!</h1>
    <p>If you can read this, your web server works 🎉</p>
  </body>
</html>' | sudo tee /var/www/html/index.html > /dev/null
```

**Result:** Apache was successfully stopped (`inactive (dead)`), then started again (`active (running)` with new PID 2624). The custom HTML file was written to `/var/www/html/index.html` using `echo | sudo tee`.

![Step 4 — Stop, start, and deploy HTML](Screenshot%202026-02-26%20101536.png)

---

## 📌 Step 5 — Verifying in the Browser

The custom HTML page was accessed from a browser by navigating to the VM's public IP address.

**URL:** `http://134.112.24.54`

**Result:** The page displayed:
- **"Hello from Apache on Ubuntu!"** as the heading
- **"If you can read this, your web server works 🎉"** as the paragraph

This confirms that Apache is serving the custom HTML page correctly and the NSG inbound rule for port 80 is working.

![Step 5 — Browser showing the custom HTML page](Screenshot%202026-02-26%20101617.png)

---

## 📌 Step 6 — Verifying with `curl` and Checking Logs

The web server was also tested from the command line using `curl`, and Apache error logs were reviewed.

**Commands executed:**
```bash
curl -I http://134.112.24.54          # Fetch HTTP headers only
curl http://134.112.24.54             # Fetch full HTML content
sudo tail -n 50 /var/log/apache2/error.log   # View last 50 lines of error log
```

### HTTP Headers Response:
```
HTTP/1.1 200 OK
Date: Thu, 26 Feb 2026 06:17:38 GMT
Server: Apache/2.4.52 (Ubuntu)
Last-Modified: Thu, 26 Feb 2026 06:13:05 GMT
Content-Length: 258
Content-Type: text/html
```

### `curl` Full Response:
The complete HTML content was returned, matching the custom page deployed.

### Apache Error Log:
The log confirmed normal operations:
- Apache configured and resuming normal operations
- Graceful shutdown (`SIGWINCH`) recorded when stopped
- Restart with new PID after `systemctl start`

![Step 6 — curl headers, content, and error log](Screenshot%202026-02-26%20102033.png)

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| **NSG Inbound Rule** | Azure firewall rule that allows HTTP traffic (port 80) to reach the VM |
| `sudo apt update` | Updates the local package index from repositories |
| `sudo apt install -y` | Installs a package without prompting for confirmation |
| `systemctl status` | Shows the current state of a systemd service |
| `systemctl stop/start` | Stops or starts a service |
| `/var/www/html/` | Default Apache web root directory |
| `sudo tee` | Writes to a file with root privileges via pipe |
| `curl -I` | Fetches only HTTP response headers |
| `curl` | Fetches the full content of a URL |
| `tail -n 50` | Shows the last 50 lines of a file |
| `/var/log/apache2/error.log` | Apache error and notice log file |
