# Lab 1: Deploy a Two-Tier Node.js Application Using Docker

## 📋 Overview

This lab demonstrates how to deploy a **two-tier application** (Node.js backend + PostgreSQL database) using Docker. Rather than using Docker Compose, each component is configured and run manually using individual Docker commands — covering volume creation, custom networking, Dockerfile creation, image building, and container orchestration. The lab also validates **data persistence** by recreating the database container and confirming that data stored in a Docker volume survives container deletion.

---

## 🎯 Objectives

- Clone a sample Node.js backend application from GitHub
- Create a Docker volume for persistent PostgreSQL data storage
- Create a custom Docker bridge network for inter-container communication
- Run a PostgreSQL container with proper environment configuration
- Write a Dockerfile for the Node.js backend application
- Build a Docker image and run the backend container
- Test the API using `curl` and a web browser
- Verify data persistence after container recreation

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Docker** | Installed and running on the host machine |
| **Git** | Installed for cloning the repository |
| **Terminal** | Bash/Zsh terminal with Docker CLI access |
| **OS** | Linux (Ubuntu recommended) / WSL on Windows |

---

## 📝 Lab Steps

### Step 1: Clone the Sample Backend Application

The sample Node.js backend application is cloned from GitHub:

```bash
git clone https://github.com/saurabhd2106/sample-backend-app-ih.git
```

![Clone Repository](Screenshots/Screenshot%202026-03-18%20110331.png)

> **Note:** This repository contains a Node.js/Express backend application that connects to a PostgreSQL database and provides a REST API for managing notes.

---

### Step 2: Create a Docker Volume and Custom Network

A named volume is created for persistent PostgreSQL data, and a custom bridge network is created to allow the containers to communicate by name:

```bash
# Create a volume for PostgreSQL data persistence
docker volume create postgres-data

# Verify the volume was created
docker volume ls

# Create a custom bridge network
docker network create my-app-network

# Verify the network was created
docker network ls
```

![Volume and Network Creation](Screenshots/Screenshot%202026-03-18%20110331.png)

**Why a Custom Network?**

| Benefit | Description |
|---|---|
| **DNS Resolution** | Containers on the same custom network can reach each other by container name |
| **Isolation** | Custom networks provide better isolation than the default bridge network |
| **Automatic DNS** | No need to use `--link` (deprecated) or IP addresses |

---

### Step 3: Run the PostgreSQL Container

The PostgreSQL container is started with the volume and network attached:

```bash
docker run -d \
  --name postgres-db \
  --network my-app-network \
  -v postgres-data:/var/lib/postgresql \
  -e POSTGRES_USER=myappuser \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=myappdb \
  postgres:latest
```

![Run PostgreSQL Container](Screenshots/Screenshot%202026-03-19%20062815.png)

**Parameter Breakdown:**

| Flag | Purpose |
|---|---|
| `-d` | Run in detached (background) mode |
| `--name postgres-db` | Assign a container name for DNS resolution |
| `--network my-app-network` | Connect to the custom network |
| `-v postgres-data:/var/lib/postgresql` | Mount the named volume for data persistence |
| `-e POSTGRES_USER` | Set the database username |
| `-e POSTGRES_PASSWORD` | Set the database password |
| `-e POSTGRES_DB` | Create an initial database on startup |

After running, `docker ps` confirms the PostgreSQL container is up and running on port `5432/tcp`.

---

### Step 4: Create the Dockerfile for the Node.js Application

Navigate into the cloned repository and create (or review) the Dockerfile:

```bash
cd sample-backend-app-ih/
nano Dockerfile
```

The Dockerfile contents:

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001

CMD ["npm", "run", "dev"]
```

![Dockerfile](Screenshots/Screenshot%202026-03-19%20062815.png)

**Dockerfile Breakdown:**

| Instruction | Purpose |
|---|---|
| `FROM node:18-alpine` | Use a lightweight Node.js 18 base image |
| `WORKDIR /app` | Set the working directory inside the container |
| `COPY package*.json ./` | Copy dependency files first (for Docker cache optimization) |
| `RUN npm install` | Install Node.js dependencies |
| `COPY . .` | Copy the rest of the application code |
| `EXPOSE 3001` | Document that the app listens on port 3001 |
| `CMD ["npm", "run", "dev"]` | Start the application in development mode |

---

### Step 5: Build the Docker Image and Run the Backend Container

Build the Node.js application image and run it on the same custom network:

```bash
# Build the Docker image
docker build -t my-node-app:latest .

# Run the backend container
docker run -d \
  --name node-backend-app \
  --network my-app-network \
  -p 3001:3001 \
  -e DATABASE_URL=postgresql://myappuser:mysecretpassword@postgres-db:5432/myappdb \
  my-node-app:latest
```

![Build and Run Backend](Screenshots/Screenshot%202026-03-19%20062932.png)

**Key Points:**
- The `DATABASE_URL` uses `postgres-db` as the hostname — this works because both containers are on the same custom network (`my-app-network`), enabling Docker's built-in DNS resolution
- Port `3001` is mapped from the container to the host for external access
- `docker ps` confirms both containers are running

---

### Step 6: Test the API with curl

Use `curl` to send a POST request to the backend API to create a note:

```bash
curl -X POST http://localhost:3001/notes \
  -H "Content-Type: application/json" \
  -d '{"title": "My Note", "content": "This is the content"}'
```

![POST Request](Screenshots/Screenshot%202026-03-19%20063057.png)

**Response:**
```json
{
  "id": 1,
  "title": "My Note",
  "content": "This is the content",
  "created_at": "2026-03-19T02:26:07.342Z",
  "updated_at": "2026-03-19T02:26:07.342Z"
}
```

✅ **Result:** The API successfully creates a note and stores it in the PostgreSQL database.

---

### Step 7: Verify via Browser and HTTP Headers

Open `http://localhost:3001/notes` in a web browser to confirm the GET endpoint returns the stored notes:

![Browser Verification](Screenshots/Screenshot%202026-03-19%20063143.png)

Additionally, verify the HTTP response headers using `curl -I`:

```bash
curl -I http://localhost:3001/notes
```

![HTTP Headers](Screenshots/Screenshot%202026-03-19%20063201.png)

**Response Headers Confirm:**
- `HTTP/1.1 200 OK` — successful response
- `X-Powered-By: Express` — Node.js/Express backend
- `Content-Type: application/json; charset=utf-8` — JSON API response
- `Access-Control-Allow-Origin: *` — CORS enabled

---

### Step 8: Verify Data Persistence After Container Recreation

To prove that data persists even when containers are removed, delete and recreate the PostgreSQL container:

```bash
# Remove the PostgreSQL container
docker rm -f postgres-db

# Recreate the PostgreSQL container with the same volume
docker run -d \
  --name postgres-db \
  --network my-app-network \
  -v postgres-data:/var/lib/postgresql \
  -e POSTGRES_USER=myappuser \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -e POSTGRES_DB=myappdb \
  postgres:latest
```

Then verify data is still intact:

```bash
# Verify the API is still working
curl -I http://localhost:3001/notes

# Create a new note to confirm write operations work
curl -X POST http://localhost:3001/notes \
  -H "Content-Type: application/json" \
  -d '{"title": "Recreate", "content": "We deleted the container and recreated it. But the information was not deleted because we saved it to the volume."}'
```

![Data Persistence Test](Screenshots/Screenshot%202026-03-19%20063933.png)

Open the browser again to confirm all notes (old and new) are present:

![Browser - Data Persisted](Screenshots/Screenshot%202026-03-19%20064013.png)

✅ **Result:** Both the original note and the newly created note are visible, confirming that Docker volumes successfully preserve data across container lifecycles.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│              my-app-network (bridge)            │
│                                                 │
│  ┌──────────────────┐  ┌─────────────────────┐  │
│  │  node-backend-app│  │    postgres-db       │  │
│  │  (Node.js/Express│  │    (PostgreSQL)      │  │
│  │   Port: 3001)    │──│    Port: 5432        │  │
│  └──────────────────┘  └──────────┬──────────┘  │
│                                   │              │
│                          ┌────────┴────────┐     │
│                          │  postgres-data   │     │
│                          │  (Docker Volume) │     │
│                          └─────────────────┘     │
└─────────────────────────────────────────────────┘
```

---

## 📊 Summary

| Task | Command | Status |
|---|---|---|
| Clone sample app | `git clone ...sample-backend-app-ih.git` | ✅ |
| Create Docker volume | `docker volume create postgres-data` | ✅ |
| Create custom network | `docker network create my-app-network` | ✅ |
| Run PostgreSQL container | `docker run -d --name postgres-db ...` | ✅ |
| Create Dockerfile | `nano Dockerfile` | ✅ |
| Build Node.js image | `docker build -t my-node-app:latest .` | ✅ |
| Run backend container | `docker run -d --name node-backend-app ...` | ✅ |
| Test API with curl | `curl -X POST ...` | ✅ |
| Verify in browser | `http://localhost:3001/notes` | ✅ |
| Verify data persistence | Remove and recreate postgres-db | ✅ |

---

## 💡 Key Takeaways

1. **Custom Docker Networks** enable containers to communicate using container names as hostnames (DNS resolution)
2. **Docker Volumes** ensure data persistence across container deletions and recreations
3. **Multi-layer Dockerfiles** with separate `COPY package*.json` and `RUN npm install` steps optimize build caching
4. **Environment variables** (like `DATABASE_URL`) provide a flexible way to configure container connections
5. **Two-tier architecture** separates the application logic (Node.js) from the data layer (PostgreSQL), following best practices
6. Manual Docker commands give **fine-grained control** but require managing each component individually — Docker Compose (covered in Lab 2) simplifies this orchestration
