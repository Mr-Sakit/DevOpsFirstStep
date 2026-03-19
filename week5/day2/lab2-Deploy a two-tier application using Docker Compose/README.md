# Lab 2: Deploy a Two-Tier Application Using Docker Compose

## 📋 Overview

This lab demonstrates how to deploy the same **two-tier application** (Node.js backend + PostgreSQL database) from Lab 1, but this time using **Docker Compose** to orchestrate both services with a single configuration file. Docker Compose simplifies multi-container management by defining all services, networks, and volumes in a declarative `docker-compose.yml` file, replacing the multiple manual `docker run` commands used in Lab 1.

---

## 🎯 Objectives

- Clone the sample Node.js backend application
- Create a Dockerfile for the backend service
- Write a `docker-compose.yml` file defining both services
- Configure networking, volumes, and environment variables declaratively
- Launch the entire stack with a single `docker compose up` command
- Understand the difference between manual Docker commands and Docker Compose

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Docker** | Installed and running on the host machine |
| **Docker Compose** | Included with Docker Desktop or installed separately |
| **Git** | Installed for cloning the repository |
| **Terminal** | Bash/Zsh terminal with Docker CLI access |
| **OS** | Linux (Ubuntu recommended) / WSL on Windows |

---

## 📝 Lab Steps

### Step 1: Clone the Repository and Create the Dockerfile

Clone the same sample backend application and create a Dockerfile:

```bash
git clone https://github.com/saurabhd2106/sample-backend-app-ih.git
cd sample-backend-app-ih/
```

Create the Dockerfile using a heredoc:

```bash
cat <<'EOF' > Dockerfile
FROM node:latest

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3001

CMD ["npm", "run", "dev"]
EOF
```

![Clone and Dockerfile](Screenshots/Screenshot%202026-03-19%20085218.png)

> **Note:** This Dockerfile uses `node:latest` (full Node.js image) unlike Lab 1 which used `node:18-alpine`. The alpine variant is smaller but the full image includes more system utilities.

---

### Step 2: Create the Docker Compose File

Create the `docker-compose.yml` file that defines both services:

```bash
nano docker-compose.yml
```

```yaml
version: "3.8"

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: notes_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  backend:
    build: .
    ports:
      - "3001:3001"
    environment:
      PORT: 3001
      DATABASE_URL: postgresql://postgres:password@postgres:5432/notes_db
      NODE_ENV: development
    depends_on:
      - postgres
    volumes:
      - .:/app
      - /app/node_modules
    networks:
      - app-network

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

![Docker Compose File](Screenshots/Screenshot%202026-03-19%20090306.png)

**Docker Compose Configuration Breakdown:**

#### Services

| Service | Image/Build | Port | Purpose |
|---|---|---|---|
| `postgres` | `postgres:15` | `5432:5432` | PostgreSQL database |
| `backend` | Build from `.` (Dockerfile) | `3001:3001` | Node.js backend API |

#### Key Configuration Details

| Configuration | Description |
|---|---|
| `depends_on: postgres` | Ensures PostgreSQL starts before the backend |
| `volumes: postgres_data` | Named volume for persistent database storage |
| `volumes: .:/app` | Bind mount for live code reloading during development |
| `volumes: /app/node_modules` | Anonymous volume to prevent host `node_modules` from overwriting container's |
| `networks: app-network` | Custom bridge network for inter-service communication |
| `DATABASE_URL` | Uses `postgres` as hostname (the service name acts as DNS) |

---

### Step 3: Launch the Stack with Docker Compose

Start all services in detached mode:

```bash
docker compose up -d
```

![Docker Compose Up](Screenshots/Screenshot%202026-03-19%20090521.png)

Docker Compose automatically:

1. **Pulled** the `postgres:15` image from Docker Hub
2. **Built** the `backend` service from the Dockerfile
3. **Created** the network (`sample-backend-app-ih_app-network`)
4. **Created** the volume (`sample-backend-app-ih_postgres_data`)
5. **Started** both containers in the correct order (postgres first, then backend)

**Output Summary:**

| Resource | Action |
|---|---|
| `sample-backend-app-ih-backend` | ✅ Built |
| `sample-backend-app-ih_app-network` | ✅ Created |
| `sample-backend-app-ih_postgres_data` | ✅ Created |
| `sample-backend-app-ih-postgres-1` | ✅ Started |
| `sample-backend-app-ih-backend-1` | ✅ Started |

---

## 🔄 Lab 1 vs Lab 2 Comparison

| Aspect | Lab 1 (Manual Docker) | Lab 2 (Docker Compose) |
|---|---|---|
| **Volume creation** | `docker volume create postgres-data` | Declared in `volumes:` section |
| **Network creation** | `docker network create my-app-network` | Declared in `networks:` section |
| **Database startup** | `docker run -d --name postgres-db ...` | Defined as `postgres` service |
| **App startup** | `docker build` + `docker run -d ...` | Defined as `backend` service with `build: .` |
| **Service ordering** | Manual (start DB first) | `depends_on` handles ordering |
| **Total commands** | 5+ separate commands | Single `docker compose up -d` |
| **Teardown** | Multiple `docker rm`, `docker network rm`, etc. | Single `docker compose down` |
| **Reproducibility** | Must remember all flags and options | All config in version-controlled YAML |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────┐
│           docker-compose.yml                         │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │            app-network (bridge)                 │ │
│  │                                                 │ │
│  │  ┌──────────────────┐  ┌─────────────────────┐ │ │
│  │  │     backend       │  │     postgres        │ │ │
│  │  │  (Node.js/Express)│  │   (PostgreSQL 15)   │ │ │
│  │  │   Port: 3001      │──│   Port: 5432        │ │ │
│  │  │   build: .        │  │   image: postgres:15│ │ │
│  │  └──────────────────┘  └──────────┬──────────┘ │ │
│  │                                   │            │ │
│  │                          ┌────────┴────────┐   │ │
│  │                          │  postgres_data   │   │ │
│  │                          │ (Named Volume)   │   │ │
│  │                          └─────────────────┘   │ │
│  └─────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

---

## 📊 Summary

| Task | Command / Action | Status |
|---|---|---|
| Clone sample app | `git clone ...sample-backend-app-ih.git` | ✅ |
| Create Dockerfile | `cat <<'EOF' > Dockerfile` | ✅ |
| Create docker-compose.yml | `nano docker-compose.yml` | ✅ |
| Launch entire stack | `docker compose up -d` | ✅ |
| Postgres pulled & started | Automatic via Compose | ✅ |
| Backend built & started | Automatic via Compose | ✅ |
| Network & volume created | Automatic via Compose | ✅ |

---

## 💡 Key Takeaways

1. **Docker Compose** replaces multiple manual `docker` commands with a single declarative YAML configuration file
2. **Service names** act as DNS hostnames within the Compose network (e.g., `postgres` in `DATABASE_URL`)
3. **`depends_on`** ensures proper startup order, though it does not wait for the service to be "ready" (consider healthchecks for production)
4. **Bind mounts** (`.:/app`) enable live code reloading during development without rebuilding the image
5. **Anonymous volumes** (`/app/node_modules`) prevent host directory mounts from overwriting container-specific files
6. **`docker compose down`** provides a clean teardown of all services, networks, and optionally volumes (`-v` flag)
7. Docker Compose configurations are **version-controlled**, making deployments reproducible and team-friendly
