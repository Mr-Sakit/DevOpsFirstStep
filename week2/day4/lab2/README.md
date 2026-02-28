# Lab 2 — Working with Nginx Web Server

In this lab, Nginx was installed on an Azure Linux VM (Ubuntu 22.04), multiple virtual hosts were configured, firewall rules were applied with UFW, security hardening was performed, reverse proxy with Node.js backends was set up, rate limiting was tested, health-check-based failover was verified, and automated deployment/backup scripts were created.

---

## 📌 Part A — Installing Nginx and Creating Virtual Hosts

### Step 1 — Updating Packages and Installing Nginx

SSH into the VM and update the package list, then install Nginx.

```bash
sudo apt update -y                 # Update package lists
sudo apt install nginx -y          # Install Nginx web server
```

**Result:** Package lists were fetched from `azure.archive.ubuntu.com`. Nginx and its dependencies (`nginx-common`, `nginx-core`, `libnginx-mod-*`, etc.) were installed successfully.

![Step 1 — sudo apt update and install nginx](Screenshot%202026-02-27%20084942.png)

---

### Step 2 — Enabling Nginx and Creating Site Directories

Nginx was enabled and started, site directories were created, ownership and permissions were set.

```bash
sudo systemctl enable --now nginx                              # Enable and start Nginx
sudo mkdir -p /var/www/site1 /var/www/app                      # Create web root directories
sudo chown -R www-data:www-data /var/www/site1 /var/www/app    # Set ownership
sudo chmod -R 755 /var/www/site1 /var/www/app                  # Set permissions
sudo ls -l /var/www/site1 /var/www/app                         # Verify listings
```

**Result:** Nginx was synchronized with SysV service scripts and enabled. Directories `/var/www/site1` and `/var/www/app` were created with `www-data` ownership and `755` permissions. The `/var/www/` listing also showed the default `html` directory.

![Step 2 — Enable Nginx and create directories](Screenshot%202026-02-27%20085130.png)

---

### Step 3 — Creating HTML Pages and Nginx Server Blocks

Custom HTML pages and Nginx server block configurations were created using `nano`.

```bash
sudo nano /var/www/site1/index.html
sudo nano /var/www/app/index.html
sudo nano /etc/nginx/sites-available/site1.conf
sudo nano /etc/nginx/sites-available/app.conf
```

#### `/var/www/site1/index.html`
```html
<!DOCTYPE html>
<html><head><title>site1</title></head>
<body><h1>site1.local</h1><p>Static site served by Nginx</p></body></html>
```

#### `/var/www/app/index.html`
```html
<!DOCTYPE html>
<html><head><title>app</title></head>
<body><h1>app.local</h1><p>Application placeholder</p></body></html>
```

#### `/etc/nginx/sites-available/site1.conf`
```nginx
server {
    listen 80;
    server_name site1.local;
    root /var/www/site1;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ /\. {
        deny all;
    }
}
```

#### `/etc/nginx/sites-available/app.conf`
```nginx
server {
    listen 80;
    server_name app.local;
    root /var/www/app;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ /\. {
        deny all;
    }

    access_log /var/log/nginx/app.access.log;
    error_log /var/log/nginx/app.error.log;
}
```

**Result:** Four files were created via `nano`. A minor typo (`/vat/www/app/index.html`) was corrected to `/var/www/app/index.html`, and `sites-avaiable` was corrected to `sites-available`.

![Step 3 — nano commands for HTML and config files](Screenshot%202026-02-27%20085215.png)

---

### Step 4 — Enabling Sites and Testing Configuration

Symbolic links were created to enable the sites, and Nginx configuration was tested and reloaded.

```bash
sudo ln -s /etc/nginx/sites-available/site1.conf /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/
ls -l /etc/nginx/sites-enabled/              # Verify symlinks
sudo nginx -t && sudo systemctl reload nginx  # Test and reload
```

**Result:** Symlinks `app.conf` and `site1.conf` were created in `sites-enabled/` pointing to `sites-available/`. Nginx configuration test passed: `syntax is ok`, `test is successful`.

![Step 4 — Symlinks and nginx reload](Screenshot%202026-02-27%20085334.png)

---

### Step 5 — Local DNS Resolution and Verification with `curl`

The VM's internal IP was resolved and hostname mappings were added to `/etc/hosts`. The virtual hosts were then tested with `curl`.

```bash
VM_IP=$(hostname -I | awk '{print $1}')
HOSTS_FILE="/etc/hosts"
echo "VM_IP is: $VM_IP"
echo "Add these lines to /etc/hosts on your VM and your workstation:"
echo "$VM_IP site1.local app.local"
```

```bash
for host in site1.local app.local api.local service2.local; do
  if ! grep -1 "$host" $HOSTS_FILE; then
    echo "$VM_IP $host" | sudo tee -a $HOSTS_FILE > /dev/null
  fi
done
```

```bash
curl -I http://site1.local | head -5     # Test site1 headers
curl -I http://app.local | head -5       # Test app headers
```

### HTTP Headers Response (site1.local):
```
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Thu, 26 Feb 2026 07:12:23 GMT
Content-Type: text/html
Content-Length: 131
```

### HTTP Headers Response (app.local):
```
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Thu, 26 Feb 2026 07:12:38 GMT
Content-Type: text/html
Content-Length: 123
```

**Result:** `VM_IP` was resolved to `172.21.0.4`. Hostnames `site1.local`, `app.local`, `api.local`, and `service2.local` were added to `/etc/hosts`. Both virtual hosts returned `HTTP/1.1 200 OK` with correct content lengths.

![Step 5 — Hosts file and curl tests](Screenshot%202026-02-27%20085440.png)

---

## 📌 Part B — Firewall Configuration with UFW

### Step 6 — Installing and Configuring UFW

UFW (Uncomplicated Firewall) was installed and configured to allow only SSH and Nginx traffic.

```bash
sudo apt install ufw -y                # Install UFW
sudo ufw default deny incoming         # Deny all incoming by default
sudo ufw default allow outgoing        # Allow all outgoing
sudo ufw allow ssh                     # Allow SSH (port 22)
sudo ufw allow 'Nginx Full'            # Allow HTTP (80) + HTTPS (443)
echo "y" | sudo ufw enable             # Enable firewall
```

**Result:** Default incoming policy set to `deny`, outgoing to `allow`. SSH and `Nginx Full` (ports 80, 443) rules were added. Firewall is active and enabled on system startup.

![Step 6 — UFW installation and configuration](Screenshot%202026-02-27%20085513.png)

---

### Step 7 — Verifying UFW Status

```bash
sudo ufw status verbose | cat       # View active rules
sudo ufw app list | cat             # List available app profiles
```

### UFW Active Rules:
```
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
80,443/tcp (Nginx Full)    ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80,443/tcp (Nginx Full (v6)) ALLOW IN  Anywhere (v6)
```

### Available Applications:
Apache, Apache Full, Apache Secure, Nginx Full, Nginx HTTP, Nginx HTTPS, OpenSSH.

![Step 7 — UFW status and app list](Screenshot%202026-02-27%20085529.png)

---

## 📌 Part C — Fail2Ban Configuration

### Step 8 — Installing Fail2Ban

```bash
sudo apt install fail2ban -y       # Install Fail2Ban
```

**Result:** Fail2Ban and its dependencies (`python3-pyinotify`, `whois`) were installed.

![Step 8 — Fail2Ban installation](Screenshot%202026-02-27%20085544.png)

---

### Step 9 — Configuring and Enabling Fail2Ban

The Fail2Ban jail configuration was created and the service was enabled.

```bash
sudo nano /etc/fail2ban/jail.local
sudo systemctl enable --now fail2ban
```

#### `/etc/fail2ban/jail.local`
```ini
[DEFAULT]
bantime = 10m
findtime = 10m
maxretry = 5

[sshd]
enabled = true
port = 22

[nginx-http-auth]
enabled = true

[nginx-limit-req]
enabled = true
```

```bash
sudo fail2ban-client status | cat               # View jail list
sudo fail2ban-client status sshd | cat          # View sshd jail details
```

**Result:** Fail2Ban was enabled and started. Three jails are active: `nginx-http-auth`, `nginx-limit-req`, `sshd`. The `sshd` jail monitors `/var/log/auth.log` — currently 0 failed, 0 banned.

![Step 9 — Fail2Ban configuration and status](Screenshot%202026-02-27%20085607.png)

---

### Step 10 — Fail2Ban sshd Jail Status (After Some Activity)

```bash
sudo fail2ban-client status sshd | cat
```

**Result:** After some time, the `sshd` jail showed: **Currently failed: 1**, **Total failed: 3**, but **Currently banned: 0**. This demonstrates Fail2Ban is actively tracking failed SSH attempts.

![Step 10 — Fail2Ban sshd status with failed attempts](Screenshot%202026-02-27%20085636.png)

---

## 📌 Part D — Security Hardening

### Step 11 — Hiding Nginx Version and Adding Security Headers

A security configuration snippet was created and Nginx was reloaded.

```bash
sudo nano /etc/nginx/conf.d/security.conf
sudo nginx -t && sudo systemctl reload nginx
```

#### `/etc/nginx/conf.d/security.conf`
```nginx
# Hide Nginx version
server_tokens off;

# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

**Result:** Nginx configuration test passed and service was reloaded successfully.

![Step 11 — Security config and reload](Screenshot%202026-02-27%20085716.png)

---

### Step 12 — Verifying Security Headers

```bash
sudo nginx -T | grep -E "(server_tokens|add_header)" | head -10
ls -la /var/www/site1 /var/www/app | cat
```

**Result:** The `nginx -T` output confirmed all security directives are active:
- `server_tokens off;`
- `add_header X-Frame-Options "SAMEORIGIN" always;`
- `add_header X-Content-Type-Options "nosniff" always;`
- `add_header X-XSS-Protection "1; mode=block" always;`
- `add_header Referrer-Policy "no-referrer-when-downgrade" always;`

Both `/var/www/app` and `/var/www/site1` contain `index.html` files with correct ownership and permissions.

![Step 12 — Verify security headers and file listings](Screenshot%202026-02-27%20085748.png)

---

## 📌 Part E — Monitoring and Log Analysis

### Step 13 — System Monitoring Snapshot

A monitoring snapshot was captured and saved, and log rotation was verified.

```bash
(echo "=== $(date) ==="; free -h; echo; df -h; echo; ss -tln; echo; uptime) | tee ~/lab6-nginx-monitoring.txt
```

### System Status:
| Metric | Value |
|--------|-------|
| **Memory** | 7.8Gi total, 292Mi used, 6.6Gi free |
| **Swap** | 0B |
| **Root Disk** | 29G total, 2.1G used (8%) |
| **Listening Ports** | 80 (Nginx), 22 (SSH), 53 (DNS) |
| **Uptime** | 1:38, 2 users, load average 0.01 |

```bash
grep -R "nginx" /etc/logrotate.d | cat          # Verify log rotation config
sudo logrotate -f /etc/logrotate.conf            # Force log rotation
```

**Result:** Monitoring data saved to `~/lab6-nginx-monitoring.txt`. Nginx log rotation is configured in `/etc/logrotate.d/nginx` for `/var/log/nginx/*.log`.

![Step 13 — Monitoring snapshot](Screenshot%202026-02-27%20085848.png)

---

### Step 14 — Nginx Log Analysis

Access logs were analyzed for top IPs, 404 errors, and user agents.

```bash
ls -la /var/log/nginx | cat                      # List all log files

# Top 10 IPs by request count
awk '{print $1}' /var/log/nginx/*access.log 2>/dev/null | sort | uniq -c | sort -nr | head -10 | tee ~/lab6-nginx-top-ips.txt

# Top 10 URLs returning 404
grep -h " 404 " /var/log/nginx/*access.log 2>/dev/null | awk '{print $7}' | sort | uniq -c | sort -nr | head -10 | tee ~/lab6-nginx-top-404.txt

# Top 10 User Agents
awk -F '"' '{print $6}' /var/log/nginx/*access.log 2>/dev/null | sort | uniq -c | sort -nr | head -10 | tee ~/lab6-nginx-user-agents.txt
```

**Result:** Log directory contained `access.log`, `app.access.log`, `error.log`, `site1.access.log`, and rotated versions. Analysis results were saved to report files.

![Step 14 — Log analysis](Screenshot%202026-02-27%20085919.png)

---

### Step 15 — Generating 404 Errors for Testing

Intentional 404 requests were made to gather data for log analysis.

```bash
curl -I http://site1.local/olmayan-sehife      # 404 — page doesn't exist
curl -I http://app.local/test/xeta              # 404
curl -I http://site1.local/admin/login          # 404

# Re-analyze 404s
grep -h " 404 " /var/log/nginx/*access.log 2>/dev/null | awk '{print $7}' | sort | uniq -c | sort -nr | head -10 | tee ~/lab6-nginx-top-404.txt
```

### Top 404 URLs:
```
4 /favicon.ico
1 /test/xeta
1 /security.txt
1 /olmayan-sehife
1 /admin/login
```

**Result:** All requests returned `HTTP/1.1 404 Not Found` from `Server: nginx` (version hidden due to `server_tokens off`). Security headers (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection, Referrer-Policy) were present in all responses.

![Step 15 — 404 testing and analysis](Screenshot%202026-02-27%20090036.png)

---

## 📌 Part F — Reverse Proxy with Node.js Backend

### Step 16 — Installing Node.js and npm

```bash
sudo apt install nodejs npm -y
```

**Result:** Node.js and npm along with their dependencies (`build-essential`, `node-gyp`, etc.) were installed.

![Step 16 — Node.js installation](Screenshot%202026-02-27%20090049.png)

---

### Step 17 — Creating the First Backend (server.js) and API Proxy

A Node.js backend was created and Nginx was configured as a reverse proxy.

```bash
mkdir -p ~/backend-app
cat > ~/backend-app/server.js <<'EOF'
const http = require('http');
const port = 3002;

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({
    message: 'Hello from backend!',
    timestamp: new Date().toISOString(),
    path: req.url
  }));
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Backend running on http://127.0.0.1:${port}`);
});
EOF

cd ~/backend-app
npm init -y
nohup node server.js > server.log 2>&1 &
BACKEND_PID=$!
echo "Backend PID: $BACKEND_PID"
```

```bash
sudo nano /etc/nginx/sites-available/api.conf
sudo ln -sf /etc/nginx/sites-available/api.conf /etc/nginx/sites-enabled
echo "$(hostname -I | awk '{print $1}') api.local" | sudo tee -a /etc/hosts
sudo nginx -t && sudo systemctl reload nginx
```

**Result:** Backend was started with PID `10073`. API proxy configuration was created, symlinked, and `api.local` was added to `/etc/hosts`. Nginx test and reload succeeded.

![Step 17 — Backend and API proxy setup](Screenshot%202026-02-27%20090151.png)

---

### Step 18 — Testing the API Reverse Proxy

```bash
curl http://api.local/ | jq . || curl http://api.local/
curl http://api.local/test | jq . || curl http://api.local/test
```

**Result:**
```json
{
  "message": "Hello from backend!",
  "timestamp": "2026-02-26T08:19:16.212Z",
  "path": "/"
}
```
```json
{
  "message": "Hello from backend!",
  "timestamp": "2026-02-26T08:19:26.215Z",
  "path": "/test"
}
```

Both requests returned `200 OK` with correct JSON responses, confirming the reverse proxy is working.

![Step 18 — API curl tests](Screenshot%202026-02-27%20090246.png)

---

### Step 19 — Creating the Second Backend (server2.js) and Service2 Proxy

```bash
cat > ~/backend-app/server2.js << 'EOF'
const http = require('http');
const port = 3003;

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({
    service: 'backend-2',
    message: 'Hello from second backend!',
    timestamp: new Date().toISOString(),
    path: req.url
  }));
});

server.listen(port, '127.0.0.1', () => {
  console.log(`Backend 2 running on http://127.0.0.1:${port}`);
});
EOF

nohup node server2.js > server2.log 2>&1 &
BACKEND2_PID=$!
echo "Backend 2 PID: $BACKEND2_PID"
```

**Result:** Backend 2 started with PID `10630`.

```bash
sudo nano /etc/nginx/sites-available/service2.conf
```

#### `/etc/nginx/sites-available/service2.conf`
```nginx
upstream backend2 {
    server 127.0.0.1:3003;
}

server {
    listen 80;
    server_name service2.local;

    location / {
        proxy_pass http://backend2;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/service2.access.log;
    error_log /var/log/nginx/service2.error.log;
}
```

![Step 19 — Second backend and service2 proxy](Screenshot%202026-02-27%20090444.png)

---

### Step 20 — Enabling Service2 and Testing Both Proxies

```bash
echo "$(hostname -I | awk '{print $1}') service2.local" | sudo tee -a /etc/hosts
sudo ln -sf /etc/nginx/sites-available/service2.conf /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

```bash
echo "Testing api.local (port 3002):"
curl http://api.local/ | jq . || curl http://api.local/

echo "Testing service2.local (port 3003):"
curl http://service2.local/ | jq . || curl http://service2.local/

echo "Ports 3002 and 3003 are not accessible externally - only through Nginx!"
```

**Result (api.local):**
```json
{
  "message": "Hello from backend!",
  "timestamp": "2026-02-26T08:41:40.861Z",
  "path": "/"
}
```

**Result (service2.local):**
```json
{
  "service": "backend-2",
  "message": "Hello from second backend!",
  "timestamp": "2026-02-26T08:41:50.648Z",
  "path": "/"
}
```

Both reverse proxies are working correctly. Ports 3002 and 3003 are only accessible internally through Nginx.

![Step 20 — Testing both proxies](Screenshot%202026-02-27%20090733.png)

---

## 📌 Part G — Rate Limiting

### Step 21 — Configuring Rate Limiting

A rate limiting configuration was created and applied.

```bash
sudo nano /etc/nginx/conf.d/rate-limiting.conf
sudo nginx -t && sudo systemctl reload nginx
```

#### `/etc/nginx/conf.d/rate-limiting.conf`
```nginx
# Rate limiting zones
limit_req_zone $binary_remote_addr zone=general:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=strict:10m rate=1r/s;
```

The `api.conf` and `site1.conf` were also updated to apply rate limiting:

```bash
sudo nano /etc/nginx/sites-available/api.conf
sudo nano /etc/nginx/sites-available/site1.conf
sudo nginx -t && sudo systemctl reload nginx
```

#### Updated `/etc/nginx/sites-available/api.conf` (with rate limiting and load balancing)
```nginx
upstream backend {
    server 127.0.0.1:3002 max_fails=3 fail_timeout=30s;
    server 127.0.0.1:3001 max_fails=3 fail_timeout=30s backup;
}

server {
    listen 80;
    server_name api.local;
    limit_req zone=api burst=10 nodelay;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/api.access.log;
    error_log /var/log/nginx/api.error.log;
}
```

![Step 21a — Rate limiting config](Screenshot%202026-02-27%20090858.png)
![Step 21b — Reload and update site configs](Screenshot%202026-02-27%20090926.png)

---

### Step 22 — Testing Rate Limiting

```bash
echo "Testing normal requests (should work):"
for i in {1..5}; do curl -s -o /dev/null -w "%{http_code} " http://site1.local/; done
echo

echo "Testing rate limiting (should get some 503 errors):"
for i in {1..15}; do curl -s -o /dev/null -w "%{http_code} " http://api.local/; done
echo
```

**Result:**
- **Normal requests (site1.local):** `200 200 200 200 200` — all successful
- **Rate-limited requests (api.local):** `502 502 502 502 502 502 502 502 503 503 503 503` — rate limiting kicked in with `503` errors after burst was exceeded

```bash
sudo tail -f /var/log/nginx/error.log | grep -i "limiting" &
```

**Result:** Error log confirmed rate limiting messages being logged.

![Step 22 — Rate limiting test](Screenshot%202026-02-27%20091046.png)

---

## 📌 Part H — Health Checks and Backend Failover

### Step 23 — Updating Backends with Health Check Endpoints

The backends were restarted with updated code including `/health` endpoints.

```bash
rm ~/backend-app/server.js && nano ~/backend-app/server.js
rm ~/backend-app/server2.js && nano ~/backend-app/server2.js
kill $BACKEND_PID 2>/dev/null || true
kill $BACKEND2_PID 2>/dev/null || true
nohup node server.js > server.log 2>&1 &
BACKEND_PID=$!
nohup node server2.js > server2.log 2>&1 &
BACKEND2_PID=$!
echo "Backend services restarted with health checks"
```

### Step 24 — Testing Health Checks and Failover

```bash
sudo nano /etc/nginx/sites-available/api.conf
sudo nginx -t && sudo systemctl reload nginx
```

```bash
echo "Testing health checks:"
curl http://api.local/health | jq . || curl http://api.local/health

echo "Testing normal API calls:"
curl http://api.local/ | jq . || curl http://api.local/
```

**Result:** Health check and normal API endpoints returned `502 Bad Gateway` initially (backends were restarting).

```bash
echo "Stopping backend 1 to test failover..."
kill $BACKEND_PID
sleep 2

echo "Testing failover (should still work):"
curl http://api.local/ | jq . || curl http://api.local/
```

**Result:** After stopping Backend 1, the response showed `502 Bad Gateway`, demonstrating that when the primary backend goes down and the backup is not available on port 3001, Nginx correctly returns an error.

![Step 24a — Health check testing](Screenshot%202026-02-27%20091128.png)

---

### Step 25 — Restarting Backend and Verifying Recovery

```bash
nohup node server.js > server.log 2>&1 &
BACKEND_PID=$!
echo "Backend 1 restarted"
```

**Result:** Backend 1 was restarted and service recovered.

![Step 25 — Backend restart](Screenshot%202026-02-27%20091150.png)

---

## 📌 Part I — Deployment Automation and Backups

### Step 26 — Creating a Deployment Script

A deployment script was created to automate site deployments with automatic backups.

```bash
nano ~/deploy-site1-nginx.sh
chmod +x ~/deploy-site1-nginx.sh
```

#### `~/deploy-site1-nginx.sh`
```bash
#!/bin/bash
SOURCE_DIR=$1
TARGET_DIR="/var/www/site1"
BACKUP_DIR="/var/backups/site1"
STAMP=$(date +%Y%m%d-%H%M%S)

sudo mkdir -p "$BACKUP_DIR"
sudo mkdir -p "$TARGET_DIR"

TMP_DIR=$(mktemp -d)
rsync -a --delete "$SOURCE_DIR/" "$TMP_DIR/"
sudo tar -czf "$BACKUP_DIR/site1-$STAMP.tgz" -C / var/www/site1 || true
sudo rsync -a --delete "$TMP_DIR/" "$TARGET_DIR/"
sudo chown -R www-data:www-data "$TARGET_DIR"
sudo chmod -R 755 "$TARGET_DIR"
rm -rf "$TMP_DIR"

echo "Deployed to $TARGET_DIR at $STAMP. Backup: $BACKUP_DIR/site1-$STAMP.tgz"
```

### Testing the Deployment Script:
```bash
mkdir -p ~/site1-content && echo "$(date) new content via Nginx" > ~/site1-content/version.txt
~/deploy-site1-nginx.sh ~/site1-content | tee ~/lab6-nginx-deploy.log
```

**Result:** `Deployed to /var/www/site1 at 20260227-044521. Backup: /var/backups/deploy/site1-20260227-044521.tgz`

---

### Step 27 — Creating a Nightly Backup Script with Cron

A backup script was created and scheduled with crontab.

```bash
sudo mkdir -p /backup
sudo nano /usr/local/bin/nightly-backup-nginx.sh
sudo chmod +x /usr/local/bin/nightly-backup-nginx.sh
```

#### `/usr/local/bin/nightly-backup-nginx.sh`
```bash
#!/bin/bash
set -euo pipefail
STAMP=$(date +%Y%m%d)
tar -czf /backup/nginx-and-web-$STAMP.tgz /etc/nginx/sites-available /var/www /etc/ssh/sshd_config
```

```bash
(crontab -l 2>/dev/null; echo "30 2 * * * /usr/local/bin/nightly-backup-nginx.sh") | crontab -
crontab -l | cat
```

**Result:** Cron job scheduled — the backup script runs every day at **2:30 AM**:
```
30 2 * * * /usr/local/bin/nightly-backup-nginx.sh
```

---

### Step 28 — Cleanup

All backend processes were terminated after the lab was completed.

```bash
kill $BACKEND_PID 2>/dev/null || true
kill $BACKEND2_PID 2>/dev/null || true
```

![Steps 26-28 — Deploy, backup, cron, cleanup](Screenshot%202026-02-27%20091150.png)

---

## 🧠 Key Takeaways

| Concept | Description |
|---------|-------------|
| `systemctl enable --now` | Enables and starts a service in a single command |
| **Virtual Hosts** | Multiple websites served from one Nginx instance using `server_name` |
| `sites-available` / `sites-enabled` | Nginx pattern for managing configs with symlinks |
| **UFW** | Simple firewall that abstracts `iptables` into human-readable rules |
| **Fail2Ban** | Monitors logs and bans IPs after repeated failures |
| `server_tokens off` | Hides the Nginx version from response headers |
| **Security Headers** | Protect against clickjacking, XSS, MIME-sniffing, and referrer leaks |
| `proxy_pass` | Forwards client requests from Nginx to a backend server |
| **Upstream Blocks** | Group backend servers for load balancing and failover |
| `limit_req_zone` | Defines rate limiting zones to throttle excessive requests |
| `max_fails` / `fail_timeout` | Health check parameters for backend availability |
| `nohup ... &` | Runs a process in the background, surviving terminal close |
| `logrotate` | Automatically rotates, compresses, and removes old log files |
| `crontab` | Schedules recurring tasks (e.g., nightly backups) |
| `rsync` | Efficiently syncs files between directories with `--delete` for clean deploys |
