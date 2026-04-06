# Lab 2: Assignment — Deploy a Three-Tier Application Using Docker

## 📋 Overview

This lab demonstrates how to deploy a **three-tier Notes application** using **Docker Compose**. The application consists of a **React frontend**, a **Node.js backend**, and a **PostgreSQL database**, all orchestrated with a single `docker-compose.yml` file. The lab covers cloning a starter repository, writing Dockerfiles for each tier, creating a Compose configuration with networking and data persistence, and verifying the full-stack application in a browser.

---

## 🎯 Objectives

- Clone a three-tier application repository from GitHub
- Write Dockerfiles for the **frontend** (React) and **backend** (Node.js) services
- Create a `docker-compose.yml` to orchestrate all three tiers (DB, Backend, Frontend)
- Configure **inter-service networking** using a custom Docker bridge network
- Implement **data persistence** using Docker volumes for PostgreSQL
- Build, run, and verify the full application stack
- Test data persistence by stopping/restarting containers

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

### Step 1: Clone the Application Repository

The three-tier application starter is cloned from GitHub:

```bash
git clone https://github.com/saurabhd2106/docker-assignment-ih.git
```

Navigate into the project directory and inspect its structure:

```bash
cd docker-assignment-ih/
ls
```

![Clone and Explore Repository](Screenshots/Screenshot%202026-04-06%20125134.png)

> **Note:** The repository contains `backend/`, `frontend/`, `test-ports.js`, and `README.md` files. The `backend` and `frontend` directories hold the Node.js API and React app source code respectively.

---

### Step 2: Create the Frontend Dockerfile

A Dockerfile is created inside the `frontend/` directory to containerize the React application:

```bash
nano frontend/Dockerfile
```

**frontend/Dockerfile contents:**

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

![Frontend Dockerfile](Screenshots/Screenshot%202026-04-06%20125459.png)

**Instruction Breakdown:**

| Instruction | Purpose |
|---|---|
| `FROM node:18-alpine` | Use lightweight Node.js 18 Alpine image as base |
| `WORKDIR /app` | Set the working directory inside the container |
| `COPY package*.json ./` | Copy dependency files first for layer caching |
| `RUN npm install` | Install Node.js dependencies |
| `COPY . .` | Copy the rest of the application source code |
| `EXPOSE 3000` | Document that the frontend runs on port 3000 |
| `CMD ["npm", "start"]` | Start the React development server |

---

### Step 3: Create the Backend Dockerfile

A Dockerfile is created inside the `backend/` directory to containerize the Node.js API:

```bash
nano backend/Dockerfile
```

**backend/Dockerfile contents:**

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3001

CMD ["node", "server.js"]
```

![Backend Dockerfile](Screenshots/Screenshot%202026-04-06%20125654.png)

**Instruction Breakdown:**

| Instruction | Purpose |
|---|---|
| `FROM node:18-alpine` | Use lightweight Node.js 18 Alpine image as base |
| `WORKDIR /app` | Set the working directory inside the container |
| `COPY package*.json ./` | Copy dependency files first for layer caching |
| `RUN npm install` | Install Node.js dependencies |
| `COPY . .` | Copy the rest of the application source code |
| `EXPOSE 3001` | Document that the backend API runs on port 3001 |
| `CMD ["node", "server.js"]` | Start the Node.js server |

---

### Step 4: Create the Docker Compose Configuration

A `docker-compose.yml` file is created to orchestrate all three services:

```bash
nano docker-compose.yml
```

**docker-compose.yml contents:**

```yaml
version: '3.8'

services:
  # Database Service (PostgreSQL)
  db:
    image: postgres:15-alpine
    container_name: notes_db_container
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: notes_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - notes_network

  # Backend Service
  backend:
    build: ./backend
    container_name: notes_backend
    restart: always
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/notes_db
      - PORT=3001
    depends_on:
      - db
    ports:
      - "3001:3001"
    networks:
      - notes_network

  # Frontend Service
  frontend:
    build: ./frontend
    container_name: notes_frontend
    restart: always
    environment:
      - REACT_APP_API_URL=http://localhost:3001
    ports:
      - "3000:3000"
    depends_on:
      - backend
    networks:
      - notes_network

networks:
  notes_network:
    driver: bridge

volumes:
  postgres_data:
```

![Docker Compose Configuration](Screenshots/Screenshot%202026-04-06%20175533.png)

**Service Configuration Breakdown:**

| Service | Image / Build | Container Name | Port Mapping | Depends On |
|---|---|---|---|---|
| **db** | `postgres:15-alpine` | `notes_db_container` | `5432:5432` | — |
| **backend** | `./backend` (custom build) | `notes_backend` | `3001:3001` | `db` |
| **frontend** | `./frontend` (custom build) | `notes_frontend` | `3000:3000` | `backend` |

**Key Configuration Details:**

| Feature | Implementation | Purpose |
|---|---|---|
| **Custom Network** | `notes_network` (bridge driver) | Enables inter-service communication by container name |
| **Named Volume** | `postgres_data` | Persists PostgreSQL data across container restarts |
| **Environment Variables** | `DATABASE_URL`, `REACT_APP_API_URL` | Configures service-to-service connectivity |
| **Restart Policy** | `restart: always` | Automatically restarts containers on failure |
| **Service Dependencies** | `depends_on` | Ensures correct startup order: DB → Backend → Frontend |

---

### Step 5: Build and Launch the Application Stack

Build all images and start the containers in detached mode:

```bash
docker-compose up --build
```

![Build Start](Screenshots/Screenshot%202026-04-06%20175716.png)

The build process completes successfully — all images are built and containers are created:

![Build Complete — Containers Created](Screenshots/Screenshot%202026-04-06%20175724.png)

**Build Output Summary:**

| Resource | Type | Status |
|---|---|---|
| `postgres:15-alpine` | Image | ✅ Pulled (13.7s) |
| `docker-assignment-ih-backend` | Image | ✅ Built (188.7s) |
| `docker-assignment-ih-frontend` | Image | ✅ Built (188.7s) |
| `docker-assignment-ih_notes_network` | Network | ✅ Created |
| `docker-assignment-ih_postgres_data` | Volume | ✅ Created |
| `notes_db_container` | Container | ✅ Created |
| `notes_backend` | Container | ✅ Created |
| `notes_frontend` | Container | ✅ Created |

---

### Step 6: Verify the Application in Browser

#### 6a. Frontend — Notes App (port 3000)

Open `http://localhost:3000` in a web browser to confirm the Notes application is running:

![Notes App — Frontend](Screenshots/Screenshot%202026-04-06%20175750.png)

✅ **Result:** The Notes App is fully functional with:
- **Create New Note** form with Title and Content fields
- **Existing Notes** displayed as cards with Edit and Delete buttons
- A test note created at **Apr 6, 2026, 12:50 PM** confirms the app is connected to the database

#### 6b. Backend Health Check (port 3001)

Open `http://localhost:3001/health` to verify the backend service:

![Backend Health Check](Screenshots/Screenshot%202026-04-06%20175853.png)

✅ **Result:** The backend returns a health status JSON response:
```json
{"status":"OK","message":"Backend is running"}
```

---

### Step 7: Test Data Persistence with Docker Volumes

To verify that the PostgreSQL volume persists data across container restarts, create a new note with instructions about persistence:

![Creating a Test Note](Screenshots/Screenshot%202026-04-06%20180204.png)

A note titled **"Test"** is created with content explaining the persistence test.

---

### Step 8: Stop and Restart Containers — Verify Persistence

**Step 8a:** Stop and remove all containers:

```bash
docker-compose down
```

![Docker Compose Down](Screenshots/Screenshot%202026-04-06%20180333.png)

All containers and the network are removed:
- ✅ Container `notes_frontend` — Removed
- ✅ Container `notes_backend` — Removed
- ✅ Container `notes_db_container` — Removed
- ✅ Network `docker-assignment-ih_notes_network` — Removed

> **Note:** The `postgres_data` volume is **NOT removed** by `docker-compose down` (only `docker-compose down -v` removes volumes), so the data persists.

After stopping, the frontend at `localhost:3000` becomes unreachable, confirming the containers are down.

**Step 8b:** Restart all containers:

```bash
docker-compose up
```

![Docker Compose Up — Data Persisted](Screenshots/Screenshot%202026-04-06%20180502.png)

✅ **Result:** After restarting, the previously created notes (**"Test"** and **"test"**) are still visible in the application, confirming that the `postgres_data` volume successfully persisted the database data across container lifecycle events.

---

## 🏗️ Architecture — Three-Tier Application

```
┌─────────────────────────────────────────────────────────────────┐
│                    THREE-TIER ARCHITECTURE                       │
│                                                                 │
│  ┌─────────────────────┐                                        │
│  │   TIER 1: FRONTEND  │  React App (Node 18 Alpine)            │
│  │   Port: 3000        │  Container: notes_frontend             │
│  │   REACT_APP_API_URL │──────────┐                             │
│  └─────────────────────┘          │                             │
│                                   │ HTTP (port 3001)            │
│  ┌─────────────────────┐          │                             │
│  │   TIER 2: BACKEND   │◄─────────┘                             │
│  │   Port: 3001        │  Node.js API (Node 18 Alpine)          │
│  │   DATABASE_URL      │──────────┐                             │
│  └─────────────────────┘          │                             │
│                                   │ PostgreSQL (port 5432)      │
│  ┌─────────────────────┐          │                             │
│  │   TIER 3: DATABASE  │◄─────────┘                             │
│  │   Port: 5432        │  PostgreSQL 15 Alpine                  │
│  │   Volume: postgres_ │  Container: notes_db_container         │
│  │   data (persistent) │                                        │
│  └─────────────────────┘                                        │
│                                                                 │
│  Network: notes_network (bridge)                                │
│  All services communicate via container names on this network   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Summary

| Task | Command / Action | Status |
|---|---|---|
| Clone three-tier app | `git clone ...docker-assignment-ih.git` | ✅ |
| Create frontend Dockerfile | `nano frontend/Dockerfile` | ✅ |
| Create backend Dockerfile | `nano backend/Dockerfile` | ✅ |
| Create docker-compose.yml | `nano docker-compose.yml` | ✅ |
| Build and launch stack | `docker-compose up --build` | ✅ |
| Verify frontend (port 3000) | `http://localhost:3000` | ✅ |
| Verify backend health (port 3001) | `http://localhost:3001/health` | ✅ |
| Create test note | Via Notes App UI | ✅ |
| Stop containers | `docker-compose down` | ✅ |
| Restart & verify persistence | `docker-compose up` | ✅ |

---

## 💡 Key Takeaways

1. **Docker Compose** simplifies multi-container application orchestration — a single `docker-compose up --build` command builds images, creates networks/volumes, and starts all services in the correct order
2. **Three-tier architecture** (Frontend → Backend → Database) is a standard pattern for modern web applications, and Docker Compose maps naturally to this architecture with one service per tier
3. **Named volumes** (`postgres_data`) persist database data beyond container lifecycles — `docker-compose down` removes containers and networks but preserves volumes by default
4. **Custom bridge networks** (`notes_network`) enable services to communicate using container names as hostnames (e.g., the backend connects to the database via `db:5432`)
5. **`depends_on`** ensures correct startup order but does not wait for services to be "ready" — for production, consider using health checks
6. **Environment variables** in Compose files allow flexible configuration of service-to-service connectivity without hardcoding URLs in application code
7. **Alpine-based images** (`node:18-alpine`, `postgres:15-alpine`) keep the overall footprint small while providing full functionality
