# Lab 3 — Shell Scripting Ops Toolkit

## Overview

In this lab, we built a **Shell Scripting Ops Toolkit** — a collection of Bash scripts designed for common DevOps operations. The toolkit includes file management, process monitoring, backup automation, log parsing, and cron-based task scheduling.

**Lab Environment:**
- Ubuntu (WSL2) on Windows
- Bash shell
- Scripts directory: `~/lab7/scripts/`
- Outputs directory: `~/lab7-outputs/`

---

## Part A — Project Scaffolding and Conventions

In this part, we set up the project structure and created a shared utility library (`common.sh`) used by all other scripts.

**Steps performed:**

```bash
set -euo pipefail
mkdir -p "$HOME/lab7/scripts" "$HOME/lab7-outputs" "$HOME/lab7/tmp"
```

Created `common.sh` with essential helper functions:

```bash
cat > "$HOME/lab7/scripts/common.sh" <<'EOF'
#!/usr/bin/bash
set -euo pipefail

LOG_DIR=${LOG_DIR:-"$HOME/lab7-outputs"}
mkdir -p "$LOG_DIR"

log() { echo "[$(date +%F_%T)] $*" | tee -a "$LOG_DIR/lab7.log"; }
die() { echo "ERROR: $*" >&2; exit 1; }
require() { command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }
EOF
```

Then sourced it and tested:

```bash
chmod +x "$HOME/lab7/scripts/common.sh"
source ~/lab7/scripts/common.sh
log "common.sh initialized from $(whoami)"
cat "$HOME/lab7-outputs/lab7.log"
```

The log file was generated successfully, recording all actions with timestamps.

![Part A — common.sh creation, source, and log test](Screenshots/Screenshot%202026-03-07%20135251.png)

---

## Part B — File Management with Shell Scripting (Mandatory)

Created `fm_tool.sh` — a flexible file management tool that supports **finding**, **archiving**, **deleting**, and **retention** of files based on patterns and age.

**Script features:**
| Flag | Description |
|------|-------------|
| `--dir` | Target directory (required) |
| `--pattern` | File glob pattern (default: `*`) |
| `--older-than` | Minimum age in days |
| `--archive` | Create `.tgz` archive of matched files |
| `--delete` | Delete matched files |
| `--dry-run` | Preview actions without executing |
| `--retention` | Keep only N latest archives |

```bash
cat > "$HOME/lab7/scripts/fm_tool.sh" <<'EOF'
#!/usr/bin/bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
# ... (full script content shown in screenshot)
EOF

chmod +x "$HOME/lab7/scripts/fm_tool.sh"
```

**Testing:**

```bash
mkdir -p "$HOME/lab7/demo"
for i in {1..5}; do echo "log $i" > "$HOME/lab7/demo/app-$i.log"; done
ls -la "$HOME/lab7/demo/"
"$HOME/lab7/scripts/fm_tool.sh" --dir "$HOME/lab7/demo" --pattern "*.log" --older-than 0 --archive --retention 3
ls -la "$HOME/lab7-outputs/"
```

The script successfully found `.log` files, created an archive (`archive-*.tgz`), and applied retention policy.

![Part B — fm_tool.sh script content (top half)](Screenshots/Screenshot%202026-03-07%20135348.png)

![Part B — fm_tool.sh test: demo files, archive, outputs](Screenshots/Screenshot%202026-03-07%20135422.png)

---

## Part C — Process Monitoring with Shell Scripting (Mandatory)

Created `proc_watch.sh` — monitors running processes by name pattern, logging CPU and memory usage, and optionally killing processes that exceed thresholds.

**Script features:**
| Flag | Description |
|------|-------------|
| `--name` | Process name pattern (required) |
| `--interval` | Sampling interval in seconds |
| `--cpu-limit` | CPU usage threshold (%) |
| `--mem-limit` | Memory limit (MB) |
| `--action` | `log` (default) or `kill` |
| `--samples` | Number of samples to take |

```bash
cat > "$HOME/lab7/scripts/proc_watch.sh" <<'EOF'
#!/usr/bin/bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
# ... (full script content shown in screenshot)
EOF

chmod +x "$HOME/lab7/scripts/proc_watch.sh"
```

**Testing:**

```bash
(sleep 120 &) ; "$HOME/lab7/scripts/proc_watch.sh" --name 'sleep\b' --samples 3 --interval 1
tail -15 "$HOME/lab7-outputs/lab7.log"
```

The script detected the background `sleep` process and logged its PID, CPU%, and memory usage across 3 samples.

![Part C — proc_watch.sh script content and test results](Screenshots/Screenshot%202026-03-07%20135446.png)

---

## Part D — Backup Files & Folders (Extra)

Created `backup.sh` — archives source directories with optional exclusion patterns and retention policies.

**Script features:**
| Flag | Description |
|------|-------------|
| `--source` | Source directory (required) |
| `--dest` | Destination directory (required) |
| `--name` | Backup name prefix |
| `--exclude` | Glob pattern to exclude |
| `--retention` | Keep only N latest backups |

```bash
cat > "$HOME/lab7/scripts/backup.sh" <<'EOF'
#!/usr/bin/bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
# ... (full script content shown in screenshot)
EOF

chmod +x "$HOME/lab7/scripts/backup.sh"
```

**Testing:**

```bash
"$HOME/lab7/scripts/backup.sh" --source "$HOME/lab7" --dest "$HOME/lab7-outputs" --name lab7 --exclude tmp --retention 3
ls -lh "$HOME/lab7-outputs/"
```

The backup archive was created and verified successfully. The `tmp` directory was excluded, and retention policy kept only the 3 latest backups.

![Part D — backup.sh script content and test results](Screenshots/Screenshot%202026-03-07%20135508.png)

---

## Part E — Log Parsing with Shell Scripting (Extra)

Created `log_parse.sh` — parses log files (nginx or syslog format) and generates summary reports.

**Script features:**
| Flag | Description |
|------|-------------|
| `--file` | Log file path (required) |
| `--type` | Log type: `nginx` or `syslog` |
| `--out` | Output directory |

For **nginx** logs, it generates: `top-ips.txt`, `top-404.txt`, `user-agents.txt`
For **syslog** logs, it generates: `top-programs.txt`, `top-error-times.txt`

```bash
cat > "$HOME/lab7/scripts/log_parse.sh" <<'EOF'
#!/usr/bin/bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
# ... (full script content shown in screenshot)
EOF

chmod +x "$HOME/lab7/scripts/log_parse.sh"
```

**Testing with system syslog:**

```bash
"$HOME/lab7/scripts/log_parse.sh" --file /var/log/syslog --type syslog --out "$HOME/lab7-outputs"
cat "$HOME/lab7-outputs/top-programs.txt"
head -10 "$HOME/lab7-outputs/top-error-times.txt"
```

The parser successfully analyzed `/var/log/syslog` and produced summary files showing the most frequent programs (e.g., `change`, `Daemon:`, `wsl-pro.service`) and error timestamps.

![Part E — log_parse.sh script content](Screenshots/Screenshot%202026-03-07%20135535.png)

![Part E — log parsing output: top-programs.txt and top-error-times.txt](Screenshots/Screenshot%202026-03-07%20135545.png)

---

## Part F — Task Scheduling with Cron (Extra)

Set up cron jobs for automated daily backup and hourly log parsing.

```bash
sudo service cron start

CRON_FILE="$HOME/lab7-outputs/lab7-cron.txt"

(crontab -l 2>/dev/null; echo "30 2 * * * $HOME/lab7/scripts/backup.sh --source $HOME/lab7 --dest $HOME/lab7-outputs --name lab7 --retention 7 >> $HOME/lab7-outputs/backup.log 2>&1") | crontab -

(crontab -l 2>/dev/null; echo "0 * * * * $HOME/lab7/scripts/log_parse.sh --file /var/log/syslog --type syslog --out $HOME/lab7-outputs >> $HOME/lab7-outputs/logparse.log 2>&1") | crontab -

crontab -l | tee "$CRON_FILE"
```

**Cron schedule:**
| Schedule | Script | Description |
|----------|--------|-------------|
| `30 2 * * *` | `backup.sh` | Daily backup at 02:30 |
| `0 * * * *` | `log_parse.sh` | Hourly syslog parse |

The cron entries were installed and exported to `lab7-cron.txt`.

![Part F — Cron job setup and verification](Screenshots/Screenshot%202026-03-07%20135558.png)

---

## Part G — End-to-End Runbook (Tie Everything Together)

Executed all four tools in sequence as a one-shot demonstration:

```bash
"$HOME/lab7/scripts/fm_tool.sh" --dir "$HOME/lab7/demo" --pattern "*.log" --older-than 0 --archive --retention 3
"$HOME/lab7/scripts/proc_watch.sh" --name 'sleep\b' --samples 2 --interval 1
"$HOME/lab7/scripts/backup.sh" --source "$HOME/lab7" --dest "$HOME/lab7-outputs" --name lab7 --exclude tmp --retention 3
"$HOME/lab7/scripts/log_parse.sh" --file /var/log/syslog --type syslog --out "$HOME/lab7-outputs"

ls -lh "$HOME/lab7-outputs/"
cat "$HOME/lab7-outputs/lab7.log"
```

All tools executed successfully, and final output directory contained all generated artifacts.

![Part G — End-to-End Runbook execution and final outputs](Screenshots/Screenshot%202026-03-07%20135617.png)

---

## Final Output — Copy to Lab Directory

Scripts and outputs were copied from the WSL environment to the lab3 directory:

```bash
mkdir -p "/mnt/c/.../week2/day5/lab3/scripts"
mkdir -p "/mnt/c/.../week2/day5/lab3/lab7-outputs"
cp "$HOME/lab7/scripts/"*.sh "/mnt/c/.../week2/day5/lab3/scripts/"
cp -r "$HOME/lab7-outputs/"* "/mnt/c/.../week2/day5/lab3/lab7-outputs/"
```

**Scripts delivered:**
- `common.sh` — Shared utility library
- `fm_tool.sh` — File management tool
- `proc_watch.sh` — Process monitoring tool
- `backup.sh` — Backup automation tool
- `log_parse.sh` — Log parsing tool

**Outputs delivered:**
- `archive-*.tgz` — File management archives
- `lab7-*.tgz` — Backup archives
- `lab7.log` — Central log file
- `lab7-cron.txt` — Cron job export
- `top-programs.txt` — Syslog program frequency report
- `top-error-times.txt` — Syslog timestamp analysis

![Final output — scripts and lab7-outputs copied to lab3 directory](Screenshots/Screenshot%202026-03-07%20135633.png)
