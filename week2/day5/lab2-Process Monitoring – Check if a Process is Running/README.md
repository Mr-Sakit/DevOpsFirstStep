# Lab 2 — Process Monitoring: Check if a Process is Running

## Overview

In this lab, we created a shell script that checks whether a given process is currently running on the system and reports its status. This is a fundamental DevOps skill used in monitoring, alerting, and automated health checks.

---

## Step 1 — Monitoring Processes with `top`

First, we used the `top` command to see all running processes and identify which ones are active:

```bash
top
```

The `top` output shows system-level metrics (CPU, memory, swap) and a list of running processes including their PID, user, CPU/memory usage, and command name. We identified `cron` as an active process to use in our script test.

![top command showing running processes — cron highlighted](Screenshots/Screenshot%202026-03-06%20212147.png)

---

## Step 2 — Creating the Process Check Script

We created a script called `check_process.sh` using `vi`:

```bash
vi check_process.sh
```

**Script content:**

```bash
#!/bin/bash
# Lab 2: Process Monitoring
# This script checks if a given process is running and reports its status.

process="cron"  # Name of the process to check (change this as needed)

# Use pgrep to search for the process by name.
# -x ensures an exact match (e.g., "cron" won't match "crond").
if pgrep -x "$process" > /dev/null; then
        echo "$process is running"
else
        echo "$process is NOT running"
fi
```

The script uses `pgrep -x` for exact process name matching and redirects output to `/dev/null` to silently check the exit code.

![check_process.sh script in vi editor — checking cron](Screenshots/Screenshot%202026-03-06%20212341.png)

---

## Step 3 — Testing with a Running Process (cron)

```bash
chmod +x check_process.sh
./check_process.sh
```

**Output:**
```
cron is running
```

The `cron` service was running on the system, so `pgrep -x cron` returned exit code 0 (success), and the script correctly printed "cron is running".

![Running check_process.sh — cron is running](Screenshots/Screenshot%202026-03-06%20212439.png)

---

## Step 4 — Testing with a Non-existent Process (FakeExample)

We modified the script to check for a non-existent process called `FakeExample`:

```bash
vi check_process.sh
```

Changed: `process="cron"` → `process="FakeExample"`

![check_process.sh modified to check FakeExample](Screenshots/Screenshot%202026-03-06%20212600.png)

```bash
./check_process.sh
```

**Output:**
```
FakeExample is NOT running
```

Since `FakeExample` is not a real process, `pgrep -x "FakeExample"` returned exit code 1 (not found), and the script correctly printed "FakeExample is NOT running".

![Running check_process.sh — FakeExample is NOT running](Screenshots/Screenshot%202026-03-06%20212622.png)

---

## Key Takeaways

| Command | Description |
|---------|-------------|
| `top` | Interactive process viewer — shows real-time system metrics |
| `pgrep -x <name>` | Search for process by exact name (returns PID or exit code 1) |
| `> /dev/null` | Suppress output (only use exit code) |
| `chmod +x` | Make script executable |
