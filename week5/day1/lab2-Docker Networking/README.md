# Lab 2: Docker Networking

## 📋 Overview

This lab explores **Docker Networking** concepts and demonstrates how to create custom networks, connect multiple containers, and enable inter-container communication. Docker provides several network drivers (bridge, host, overlay, none) that allow containers to communicate with each other and the outside world. In this lab, we focus on creating a custom **bridge network** and connecting containers to it.

---

## 🎯 Objectives

- Understand Docker's default networking behavior
- Create a custom bridge network
- Run containers on a custom network
- Test container-to-container communication using container names (DNS resolution)
- Inspect Docker networks
- Disconnect and remove networks

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Docker** | Installed and running on the host machine |
| **Terminal** | Bash/Zsh terminal with Docker CLI access |
| **OS** | Linux (Ubuntu recommended) / WSL on Windows |

---

## 🌐 Docker Network Types

| Network Driver | Description |
|---|---|
| **bridge** | Default network driver. Containers on the same bridge can communicate |
| **host** | Removes network isolation; container shares the host's network |
| **overlay** | Enables multi-host networking for Docker Swarm services |
| **none** | Disables all networking for the container |
| **macvlan** | Assigns a MAC address, making the container appear as a physical device |

---

## 📝 Lab Steps

### Step 1: List Default Networks

View the existing Docker networks:

```bash
docker network ls
```

By default, Docker provides three networks: `bridge`, `host`, and `none`.

---

### Step 2: Create a Custom Bridge Network

Create a user-defined bridge network:

```bash
docker network create my-custom-network
```

![Create Custom Network](Screenshots/Screenshot%202026-03-17%20093524.png)

> **Why Custom Networks?** Unlike the default bridge network, custom bridge networks provide automatic DNS resolution between containers, meaning containers can reach each other by name instead of IP address.

---

### Step 3: Run Containers on the Custom Network

Launch two containers connected to the custom network:

```bash
# Container 1 - Nginx web server
docker run -d --name web-server --network my-custom-network nginx:latest

# Container 2 - Alpine for testing
docker run -it --name test-client --network my-custom-network alpine sh
```

---

### Step 4: Test Container-to-Container Communication

From inside the `test-client` container, ping the `web-server` container by name:

```bash
ping web-server
```

You can also use `wget` or `curl` to reach the Nginx server:

```bash
wget -qO- http://web-server
```

![Container Communication](Screenshots/Screenshot%202026-03-17%20094401.png)

✅ **Result:** The `test-client` container can successfully resolve and communicate with `web-server` using its container name as the hostname.

---

### Step 5: Inspect the Network

View detailed information about the custom network:

```bash
docker network inspect my-custom-network
```

![Network Inspect](Screenshots/Screenshot%202026-03-17%20094413.png)

This command shows:
- Network ID and name
- IPAM configuration (subnet, gateway)
- Connected containers with their IP addresses
- Network driver and scope

---

### Step 6: Disconnect and Cleanup

Disconnect a container from the network and clean up:

```bash
# Disconnect container from network
docker network disconnect my-custom-network web-server

# Stop and remove containers
docker stop web-server test-client
docker rm web-server test-client

# Remove the custom network
docker network rm my-custom-network
```

---

## 📊 Summary

| Task | Command | Status |
|---|---|---|
| List networks | `docker network ls` | ✅ |
| Create custom network | `docker network create my-custom-network` | ✅ |
| Run containers on network | `docker run --network my-custom-network ...` | ✅ |
| Test DNS resolution | `ping web-server` from test-client | ✅ |
| Inspect network | `docker network inspect my-custom-network` | ✅ |
| Cleanup | Disconnect, remove containers and network | ✅ |

---

## 💡 Key Takeaways

1. **Custom bridge networks** enable automatic DNS-based service discovery between containers
2. Containers on the **default bridge network** can only communicate by IP address, not by name
3. **Network isolation** prevents containers on different networks from communicating unless explicitly connected
4. `docker network inspect` provides detailed information about connected containers and IP assignments
5. Docker networking is foundational for **multi-container applications** and **Docker Compose** setups
6. Always clean up unused networks with `docker network prune` to keep the environment tidy
