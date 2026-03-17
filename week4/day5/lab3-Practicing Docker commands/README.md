# Lab 3: Practicing Docker Commands

## 📋 Overview

This lab provides hands-on practice with essential **Docker CLI commands**. It covers the complete container lifecycle — from pulling images, running and managing containers, to inspecting, stopping, and removing them. These commands form the foundation of daily Docker operations and are essential for any DevOps engineer.

---

## 🎯 Objectives

- Pull Docker images from Docker Hub
- Run containers in interactive and detached modes
- List, inspect, and manage running containers
- Execute commands inside running containers
- View container logs and resource usage
- Stop, restart, and remove containers
- Manage Docker images and volumes

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Docker** | Installed and running on the host machine |
| **Terminal** | Bash/Zsh terminal with Docker CLI access |

---

## 📝 Lab Steps

### Step 1: Working with Docker Images

#### Pull an image:

```bash
docker pull nginx:latest
docker pull alpine:latest
```

#### List all local images:

```bash
docker images
```

![Docker Images](Screenshots/Screenshot%202026-03-16%20091850.png)

#### Inspect image details:

```bash
docker inspect nginx:latest
```

---

### Step 2: Running Containers

#### Run in detached mode:

```bash
docker run -d --name my-nginx -p 8080:80 nginx:latest
```

#### Run in interactive mode:

```bash
docker run -it --name my-alpine alpine:latest sh
```

![Running Containers](Screenshots/Screenshot%202026-03-16%20092103.png)

**Common `docker run` flags:**

| Flag | Description |
|---|---|
| `-d` | Detached mode (background) |
| `-it` | Interactive mode with terminal |
| `--name` | Assign a custom name |
| `-p host:container` | Port mapping |
| `-v host:container` | Volume mount |
| `-e KEY=VALUE` | Set environment variable |
| `--rm` | Auto-remove on exit |
| `--network` | Connect to a specific network |

---

### Step 3: Managing Running Containers

#### List running containers:

```bash
docker ps
```

#### List all containers (including stopped):

```bash
docker ps -a
```

![List Containers](Screenshots/Screenshot%202026-03-16%20092342.png)

#### View container details:

```bash
docker inspect my-nginx
```

---

### Step 4: Executing Commands in Containers

Run a command inside a running container:

```bash
docker exec -it my-nginx bash
```

Once inside, you can explore the container filesystem:

```bash
ls /usr/share/nginx/html/
cat /etc/nginx/nginx.conf
exit
```

![Exec into Container](Screenshots/Screenshot%202026-03-16%20093455.png)

---

### Step 5: Container Logs and Monitoring

#### View container logs:

```bash
docker logs my-nginx
docker logs --follow my-nginx  # Follow logs in real-time
```

#### View resource usage:

```bash
docker stats --no-stream
```

![Container Logs & Stats](Screenshots/Screenshot%202026-03-16%20094056.png)

This displays:
- CPU and memory usage
- Network I/O
- Block I/O
- Process IDs

---

### Step 6: Container Lifecycle Management

#### Stop a container:

```bash
docker stop my-nginx
```

#### Start a stopped container:

```bash
docker start my-nginx
```

#### Restart a container:

```bash
docker restart my-nginx
```

#### Pause/Unpause:

```bash
docker pause my-nginx
docker unpause my-nginx
```

![Lifecycle Management](Screenshots/Screenshot%202026-03-16%20094126.png)

---

### Step 7: Cleanup

#### Remove stopped containers:

```bash
docker rm my-nginx my-alpine
```

#### Remove images:

```bash
docker rmi nginx:latest alpine:latest
```

#### System-wide cleanup:

```bash
# Remove all stopped containers, unused networks, dangling images
docker system prune

# Remove everything including unused images
docker system prune -a
```

![Cleanup](Screenshots/Screenshot%202026-03-16%20094751.png)

---

## 📊 Docker Commands Quick Reference

| Category | Command | Description |
|---|---|---|
| **Images** | `docker pull <image>` | Pull an image |
| | `docker images` | List local images |
| | `docker rmi <image>` | Remove an image |
| **Containers** | `docker run ...` | Create and start a container |
| | `docker ps` | List running containers |
| | `docker ps -a` | List all containers |
| | `docker exec -it <name> <cmd>` | Execute a command inside a container |
| | `docker logs <name>` | View container logs |
| | `docker stats` | View resource usage |
| **Lifecycle** | `docker stop <name>` | Stop a container |
| | `docker start <name>` | Start a stopped container |
| | `docker restart <name>` | Restart a container |
| | `docker rm <name>` | Remove a container |
| **System** | `docker system prune` | Clean up unused resources |
| | `docker inspect <name>` | View detailed information |

---

## 💡 Key Takeaways

1. **Detached mode** (`-d`) is preferred for long-running services; **interactive mode** (`-it`) for debugging and exploration
2. `docker exec` is essential for troubleshooting running containers without stopping them
3. `docker logs` and `docker stats` are vital monitoring tools for containerized applications
4. Always name your containers (`--name`) for easier management and referenceability
5. Regular cleanup with `docker system prune` prevents disk space issues
6. Understanding the container lifecycle (create → start → stop → remove) is fundamental to Docker mastery
