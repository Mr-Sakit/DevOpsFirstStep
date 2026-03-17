# Lab 1: Docker Installation Lab Guide

## 📋 Overview

This lab covers the complete installation and setup of **Docker Engine** on an Ubuntu Linux system. Docker is a platform for developing, shipping, and running applications inside lightweight, portable containers. This guide walks through adding Docker's official repository, installing the Docker Engine and CLI tools, verifying the installation, and running the classic `hello-world` container.

---

## 🎯 Objectives

- Set up Docker's official APT repository
- Install Docker Engine, CLI, and related plugins
- Verify the installation by running a test container
- Understand Docker's architecture and components

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **OS** | Ubuntu 22.04+ / Debian-based distribution |
| **Access** | `sudo` privileges on the machine |
| **Network** | Internet connectivity for downloading packages |

---

## 📝 Lab Steps

### Step 1: Set Up Docker's APT Repository

Update the package index and install prerequisite packages:

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install ca-certificates curl

# Create the keyrings directory
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker's official GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker's repository to APT sources
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt-get update
```

![Docker Repository Setup](Screenshots/Screenshot%202026-03-13%20061816.png)

> **Why Official Repository?** Using Docker's official repository ensures you get the latest stable version, security patches, and proper package signatures.

---

### Step 2: Install Docker Engine

Install Docker Engine along with the CLI tools and plugins:

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

![Docker Installation](Screenshots/Screenshot%202026-03-13%20061948.png)

**Installed Components:**

| Package | Description |
|---|---|
| `docker-ce` | Docker Engine (Community Edition) |
| `docker-ce-cli` | Command-line interface for Docker |
| `containerd.io` | Container runtime |
| `docker-buildx-plugin` | Extended build capabilities with BuildKit |
| `docker-compose-plugin` | Multi-container orchestration tool |

---

### Step 3: Verify the Installation

Run the `hello-world` container to verify Docker is installed correctly:

```bash
sudo docker run hello-world
```

![Hello World Verification](Screenshots/Screenshot%202026-03-13%20062343.png)

✅ **Result:** The `hello-world` container runs successfully, confirming that Docker Engine is properly installed and the Docker daemon is running.

**What happens behind the scenes:**
1. Docker client contacts the Docker daemon
2. Daemon pulls the `hello-world` image from Docker Hub (if not cached locally)
3. Daemon creates a new container from the image
4. Container runs and outputs the confirmation message
5. Container exits

---

### Step 4: Post-Installation Configuration (Optional)

To run Docker commands without `sudo`, add your user to the `docker` group:

```bash
sudo usermod -aG docker $USER
```

Then log out and back in, or run:

```bash
newgrp docker
```

Verify it works without `sudo`:

```bash
docker run hello-world
```

![Post-Install Config](Screenshots/Screenshot%202026-03-13%20062735.png)

> **Security Note:** Adding users to the `docker` group grants them root-level privileges over the Docker daemon. Only add trusted users.

---

## 📊 Summary

| Task | Command | Status |
|---|---|---|
| Set up APT repository | `sudo apt-get install ...` + GPG key | ✅ |
| Install Docker Engine | `sudo apt-get install docker-ce ...` | ✅ |
| Verify installation | `sudo docker run hello-world` | ✅ |
| Configure non-root access | `sudo usermod -aG docker $USER` | ✅ |

---

## 💡 Key Takeaways

1. Always use Docker's **official repository** for production-grade installations
2. Docker consists of multiple components: **Engine**, **CLI**, **containerd**, and **plugins**
3. The `hello-world` container is the standard way to verify a Docker installation
4. Post-installation steps like adding users to the `docker` group improve workflow ergonomics
5. Docker uses a **client-server architecture** where the CLI communicates with the Docker daemon
