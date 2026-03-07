# Lab 3 — System Administration Fundamentals

In this lab, core system administration commands were practiced on an Azure Linux VM (Ubuntu 22.04): system information gathering, package management, process management, service management, network diagnostics, and web server preparation.

---

## 📌 Part A — System Information

### Step 1 — OS and Kernel Information

```bash
uname -a                    # Kernel and system architecture
cat /etc/os-release          # OS version details
```

**Result:**
- **Kernel:** `Linux rg-lab-azurevm-sakit 6.8.0-1041-azure #47~22.04.1-Ubuntu SMP Fri Oct 3 20:43:01 UTC 2025 x86_64`
- **OS:** `Ubuntu 22.04.5 LTS (Jammy Jellyfish)`
- **VERSION_CODENAME:** `jammy`

---

### Step 2 — User Information

```bash
whoami                       # Current username
id                           # User ID and group memberships
```

**Result:**
- **User:** `mr-sakit`
- **UID/GID:** `uid=1000(mr-sakit) gid=1000(mr-sakit)`
- **Groups:** `adm`, `dialout`, `cdrom`, `floppy`, `sudo`, `audio`, `dip`, `video`, `plugdev`, `netdev`, `lxd`

---

### Step 3 — Memory, Disk, and Uptime

```bash
free -h                      # RAM and swap usage
df -h                        # Disk partitions
du -sh ~                     # Home directory size
uptime                       # System uptime
```

**Result:**

| Metric | Value |
|--------|-------|
| **RAM** | 7.8Gi total, 281Mi used, 7.0Gi free |
| **Swap** | 0B |
| **Root Disk (/)** | 29G total, 2.9G used (10%) |
| **Home (~)** | 140K |
| **Uptime** | 2 min, 1 user, load average: 0.15, 0.17, 0.07 |

![Steps 1-3 — System information](Screenshots/Screenshot%202026-03-02%20092244.png)

---

## 📌 Part B — System Report Script

### Step 4 — Creating the Lab Directory

```bash
mkdir -p ~/sys-admin-lab         # Create lab directory
cd ~/sys-admin-lab               # Navigate into it
```

![Step 4 — Directory creation](Screenshots/Screenshot%202026-03-02%20092751.png)

---

### Step 5 — Creating and Running system-info.txt Script

A script was created to gather system information into a report.

```bash
cat << EOF > system-info.txt
echo "=== System Information ==="
echo "OS: \$(cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2)"
echo "Kernel: \$(uname -r)"
echo "Architecture: \$(uname -m)"
echo "Current User: \$(whoami)"
echo "Home Directory: \$HOME"
EOF
```

```bash
bash system-info.txt > system-report.txt
cat system-report.txt
```

**Result (`system-report.txt`):**
```
=== System Information ===
OS: "Ubuntu 22.04.5 LTS"
Kernel: 6.8.0-1041-azure
Architecture: x86_64
Current User: mr-sakit
Home Directory: /home/mr-sakit
```

---

### Step 6 — Detecting the Package Manager

```bash
which apt yum dnf pacman zypper 2>/dev/null || echo "Package manager not found"
```

**Result:** `/usr/bin/apt` — the system uses the `apt` package manager.

```bash
sudo apt update              # Update package lists
```

**Result:** Package lists were fetched from `azure.archive.ubuntu.com`.

![Steps 5-6 — System report and apt update](Screenshots/Screenshot%202026-03-02%20092811.png)

---

## 📌 Part C — Package Management

### Step 7 — Searching and Installing htop

```bash
apt search htop 2>/dev/null || yum search htop 2>/dev/null || dnf search htop 2>/dev/null
```

**Result:** `htop` found — `htop/jammy,now 3.0.5-7build2 amd64 [installed,automatic]` — already installed.

```bash
sudo apt install htop -y 2>/dev/null || sudo yum install htop -y 2>/dev/null || sudo dnf install htop -y 2>/dev/null
which htop                   # Verify htop path
htop --version               # Check version
```

**Result:**
- `htop is already the newest version (3.0.5-7build2)`
- **Path:** `/usr/bin/htop`
- **Version:** `htop 3.0.5`

![Step 7 — htop search and install](Screenshots/Screenshot%202026-03-02%20092839.png)

---

### Step 8 — Installing curl, wget, and tree

```bash
sudo apt install curl wget tree -y 2>/dev/null || sudo yum install curl wget tree -y 2>/dev/null || sudo dnf install curl wget tree -y 2>/dev/null
```

**Result:** `curl` and `libcurl4` were upgraded, `tree` was newly installed. `wget` was already at the latest version.

```bash
curl --version | head -1     # curl 7.81.0
wget --version | head -1     # GNU Wget 1.21.2
tree --version               # tree v2.0.2
```

![Step 8 — curl, wget, tree installation](Screenshots/Screenshot%202026-03-02%20092906.png)

---

### Step 9 — Listing Installed Packages and Processes

```bash
dpkg -l | head -10 2>/dev/null || rpm -qa | head -10 2>/dev/null
dpkg -l | grep htop 2>/dev/null || rpm -qa | grep htop 2>/dev/null
```

**Result:** Installed packages include `adduser`, `adwaita-icon-theme`, `apache2`, `apache2-bin`, `apache2-data`, and `htop`.

```bash
ps aux | head -10            # First 10 processes
ps auxf | head -20           # Process tree view
```

**Result:** `ps aux` showed the top processes — PID 1 (`/sbin/init`), kernel threads (`kthreadd`, `pool_workqueue_release`, `kworker`, `R-netns`). `ps auxf` displayed the same information in a tree structure.

![Step 9 — Packages and processes](Screenshots/Screenshot%202026-03-02%20092922.png)

---

## 📌 Part D — Process Management

### Step 10 — top and Real-Time Monitoring

```bash
top -n 5                     # top — 5 iterations
```

**Result:**
- **Uptime:** 32 min, 1 user
- **Tasks:** 130 total, 1 running, 129 sleeping
- **CPU:** 0.2% us, 99.7% id
- **RAM:** 7943.9 MiB total, 301.7 used, 6769.0 free
- **Top CPU consumers:** `fail2ban-server` (PID 709), `top` (PID 2170), `systemd` (PID 1)

![Step 10 — top command](Screenshots/Screenshot%202026-03-02%20093002.png)

---

### Step 11 — pstree and Background Jobs

```bash
pstree | head -20            # Process tree
```

**Result:** `systemd` is the root process. Child processes include: `chronyd`, `cron`, `dbus-daemon`, `fail2ban-server`, `nginx` (2 workers), `packagekitd`, `snapd`, `sshd`→`bash`→`pstree`.

```bash
sleep 300 &                  # Start background process
jobs                         # List background jobs
fg %1                        # Bring to foreground
```

**Result:**
- `[1] 2259` — `sleep 300` started in background
- `jobs` output: `[1]+ Running sleep 300 &`
- `fg %1` brought it to the foreground

![Step 11 — pstree and background jobs](Screenshots/Screenshot%202026-03-02%20093130.png)

---

### Step 12 — Killing a Process

```bash
sleep 200 &                  # New background process
kill %1                      # Terminate it
jobs                         # Check status
```

**Result:**
- `[1] 2359` — new process created
- `kill %1` — process terminated
- `jobs` output: `[1]+ Terminated sleep 200`

---

## 📌 Part E — Service Management

### Step 13 — Listing Services

```bash
systemctl list-units --type=service | head -10
systemctl list-units --type=service --state=running | head -5
systemctl list-units --type=service --state=active | head -5
```

**Running services:**
- `chrony.service` — NTP client/server
- `cron.service` — Background program processing
- `dbus.service` — D-Bus System Message Bus
- `fail2ban.service` — Fail2Ban Service

**Active (exited) services:** `apparmor`, `apport`, `blk-availability`, `chrony`

---

### Step 14 — SSH Service Status

```bash
systemctl status ssh 2>/dev/null || systemctl status sshd 2>/dev/null
```

**Result:**
```
● ssh.service - OpenBSD Secure Shell server
   Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
   Active: active (running) since Mon 2026-03-02 04:23:39 UTC; 45min ago
   Main PID: 761 (sshd)
   Tasks: 1 (limit: 9523)
   Memory: 7.8M
   CPU: 451ms
```

SSH logs revealed multiple invalid login attempts from various IPs using usernames like `solana`, `ubuntu`, `solv`, `sol` — actively tracked by Fail2Ban.

![Steps 12-14 — kill, systemctl, SSH status](Screenshots/Screenshot%202026-03-02%20093222.png)

---

### Step 15 — Checking for Web Servers

```bash
which apache2 2>/dev/null || which httpd 2>/dev/null || echo "Apache not installed"
which nginx 2>/dev/null || echo "Nginx not installed"
apt search apache2 2>/dev/null | head -5 || yum search httpd 2>/dev/null | head -5
```

**Result:**
- **Apache2:** `/usr/sbin/apache2` — installed
- **Nginx:** `/usr/sbin/nginx` — installed
- **Apache2 version:** `2.4.52-1ubuntu4.18 amd64 [installed]`

---

### Step 16 — Checking Network Service

```bash
systemctl status networking 2>/dev/null || systemctl status NetworkManager 2>/dev/null
```

**Result:** Neither service was found (Azure VM networking is managed by `cloud-init`).

![Steps 15-16 — Web server and network checks](Screenshots/Screenshot%202026-03-02%20093246.png)

---

## 📌 Part F — Service Status Check Script

### Step 17 — check-services.sh Script

```bash
cat > check-services.sh << 'EOF'
#!/bin/bash
echo "=== Service Status Check ==="
echo "SSH Service:"
systemctl is-active ssh 2>/dev/null || systemctl is-active sshd 2>/dev/null || echo "SSH service not found"
echo "Network Service:"
systemctl is-active networking 2>/dev/null || systemctl is-active NetworkManager 2>/dev/null || echo "Network service not found"
echo "System Time:"
date
EOF

chmod +x check-services.sh
./check-services.sh
```

**Result:**
```
=== Service Status Check ===
SSH Service:
active
Network Service:
inactive
inactive
Network service not found
System Time:
Mon Mar  2 05:16:08 UTC 2026
```

![Step 17 — check-services.sh](Screenshots/Screenshot%202026-03-02%20093349.png)

---

## 📌 Part G — Network Diagnostics

### Step 18 — IP Addresses and Routing

```bash
ip addr show | head -20      # Network interfaces
ip route show                # Routing table
ping -c 3 8.8.8.8            # Ping Google DNS
```

**Result:**
- **lo:** `127.0.0.1/8` (loopback)
- **eth0:** `172.21.0.4/24` — primary network interface
- **enP48170s1:** slave interface (master: eth0)
- **Default Gateway:** `172.21.0.1 dev eth0`
- **Ping:** 3 packets sent, 3 received, 0% loss, avg RTT: `1.256 ms`

![Step 18 — Network information](Screenshots/Screenshot%202026-03-02%20093432.png)

---

### Step 19 — DNS Lookups

```bash
nslookup google.com 2>/dev/null || dig google.com 2>/dev/null || echo "DNS tools not available"
host google.com 2>/dev/null || echo "host command not available"
```

**Result:**
- **DNS Server:** `127.0.0.53` (systemd-resolved)
- **google.com IPv4:** `142.250.109.102`, `142.250.109.113`, `142.250.109.138`, `142.250.109.101`, `142.250.109.139`, `142.250.109.100`
- **google.com IPv6:** `2a00:1450:4025:800::71`, `2a00:1450:4025:800::66`, `2a00:1450:4025:800::64`, `2a00:1450:4025:800::8b`
- **Mail:** `google.com mail is handled by 10 smtp.google.com.`

![Step 19 — DNS lookups](Screenshots/Screenshot%202026-03-02%20093442.png)

---

## 📌 Part H — Network Diagnostic Script

### Step 20 — Port Checking and network-check.sh

```bash
ss -tlnp | head -10 2>/dev/null || netstat -tlnp | head -10 2>/dev/null
ss -tlnp | grep :22 2>/dev/null || netstat -tlnp | grep :22 2>/dev/null
```

**Result:**

| Port | Address | Service |
|------|---------|---------|
| 22 | 0.0.0.0 | SSH |
| 80 | 0.0.0.0 | Nginx/Apache |
| 53 | 127.0.0.53%lo | DNS (systemd-resolved) |

```bash
cat > network-check.sh << 'EOF'
#!/bin/bash
echo "=== Network Diagnostic Report ==="
echo "Date: $(date)"
echo ""
echo "Network Interfaces:"
ip addr show | grep -E "(inet |UP|DOWN)"
echo ""
echo "Default Gateway:"
ip route | grep default
echo ""
echo "DNS Servers:"
cat /etc/resolv.conf | grep nameserver
echo ""
echo "Internet Connectivity:"
ping -c 2 8.8.8.8 > /dev/null 2>&1 && echo "✓ Internet accessible" || echo "✗ No internet access"
EOF

chmod +x network-check.sh
./network-check.sh
```

**Result:**
```
=== Network Diagnostic Report ===
Date: Mon Mar  2 05:18:18 UTC 2026

Network Interfaces:
1: lo: <LOOPBACK,UP,LOWER_UP> ...
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> ...
    inet 172.21.0.4/24 metric 100 brd 172.21.0.255 scope global eth0
3: enP48170s1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> ...

Default Gateway:
default via 172.21.0.1 dev eth0 proto dhcp src 172.21.0.4 metric 100

DNS Servers:
nameserver 127.0.0.53

Internet Connectivity:
✓ Internet accessible
```

![Step 20 — Port checking and network-check.sh](Screenshots/Screenshot%202026-03-02%20093700.png)

---

## 📌 Part I — Web Server Preparation

### Step 21 — Creating /var/www/html and a Test Page

```bash
sudo mkdir -p /var/www/html
sudo chown -R $USER:$USER /var/www/html 2>/dev/null || sudo chown -R $USER /var/www/html
```

```bash
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Page</title>
</head>
<body>
    <h1>Hello from Linux Lab!</h1>
    <p>This is a test page for tomorrow's Apache lab.</p>
    <p>Current time: <script>document.write(new Date());</script></p>
</body>
</html>
EOF
```

```bash
chmod 644 /var/www/html/index.html
ls -la /var/www/html/
cat /var/www/html/index.html
```

**Result:** `index.html` was created in `/var/www/html/` (253 bytes). `ls -la` showed both `index.html` and `index.nginx-debian.html` present in the directory. File contents were verified.

![Step 21 — Web server preparation](Screenshots/Screenshot%202026-03-02%20093719.png)

---

## 📌 Part J — Lab Summary

### Step 22 — lab3-summary.txt Script

```bash
cat > lab3-summary.txt << 'EOF'
=== Lab 3 Summary ===
Date: $(date)
User: $(whoami)
System: $(uname -a)

Tools Installed:
- htop: $(which htop)
- curl: $(which curl)
- wget: $(which wget)
- tree: $(which tree)

Key Commands Learned:
- System monitoring: free, df, uptime, ps, htop
- Package management: apt/yum install, search
- Process management: jobs, fg, bg, kill
- Service management: systemctl status
- Network diagnostics: ip, ping, ss/netstat

Web Server Preparation:
- Created /var/www/html directory
- Created test index.html file
- Ready for Apache installation tomorrow
EOF

cat lab3-summary.txt
```

**Result:** The summary file was created and displayed successfully. Note that `$(...)` expressions were kept as literal text because `'EOF'` (single-quoted) was used, preventing variable expansion.

![Step 22 — Lab3 summary](Screenshots/Screenshot%202026-03-02%20093727.png)

---

## 🧠 Key Takeaways

| Command | Description |
|---------|-------------|
| `uname -a` | Kernel, architecture, and OS info |
| `cat /etc/os-release` | Linux distribution details |
| `whoami` / `id` | Username and group memberships |
| `free -h` | RAM and swap usage |
| `df -h` | Disk partitions and free space |
| `apt search/install` | Package search and installation |
| `dpkg -l` | List installed packages |
| `ps aux` / `ps auxf` | Process listing (flat/tree) |
| `top -n 5` | Real-time process monitoring |
| `pstree` | Process tree structure |
| `jobs` / `fg` / `bg` / `kill` | Background process management |
| `systemctl list-units` | List services |
| `systemctl status` | Check service status |
| `ip addr show` | Network interfaces |
| `ip route show` | Routing table |
| `ss -tlnp` | Open ports and listening services |
| `ping` / `nslookup` / `host` | Network connectivity and DNS |
