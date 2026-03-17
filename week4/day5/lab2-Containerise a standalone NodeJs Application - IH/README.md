# Lab 2: Containerise a Standalone Node.js Application

## 📋 Overview

This lab demonstrates how to containerize a standalone **Node.js** application using Docker. The process includes cloning a sample application, writing a `Dockerfile`, building a Docker image, running the containerized application, and verifying it works correctly. This is a fundamental DevOps skill for creating portable, reproducible application deployments.

---

## 🎯 Objectives

- Clone a sample Node.js application from GitHub
- Write a production-ready Dockerfile
- Build a Docker image from the Dockerfile
- Run the containerized application
- Test the application in the browser
- Understand Dockerfile best practices

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Docker** | Installed and running on the host machine |
| **Git** | Installed for cloning the repository |
| **Terminal** | Bash/Zsh terminal with Docker CLI access |

---

## 📝 Lab Steps

### Step 1: Clone the Sample Application

Clone the sample Node.js application from GitHub:

```bash
cd ~/projects/lab
git clone https://github.com/saurabhd2106/sample-nodejs-app-ih
cd sample-nodejs-app-ih
ls
```

![Clone Repository](Screenshots/Screenshot%202026-03-16%20110439.png)

The project structure contains:
- `server.js` — Main application file
- `package.json` — Node.js dependencies
- `public/` — Static assets
- `README.md` — Project documentation

---

### Step 2: Create a Dockerfile

Create a `Dockerfile` in the project root using a text editor:

```bash
nano Dockerfile
```

**Dockerfile contents:**

```dockerfile
# Use an official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port that the app runs on
EXPOSE 3000

# Define the command to run the app
CMD ["node", "server.js"]
```

![Dockerfile](Screenshots/Screenshot%202026-03-16%20110530.png)

**Dockerfile Breakdown:**

| Instruction | Purpose |
|---|---|
| `FROM node:18-alpine` | Uses Node.js 18 on Alpine Linux (minimal, ~50MB) |
| `WORKDIR /app` | Sets the working directory inside the container |
| `COPY package*.json ./` | Copies dependency files first (for caching) |
| `RUN npm install` | Installs Node.js dependencies |
| `COPY . .` | Copies the rest of the source code |
| `EXPOSE 3000` | Documents that the app listens on port 3000 |
| `CMD ["node", "server.js"]` | Defines the startup command |

> **Best Practice:** Copying `package.json` and running `npm install` before copying the source code leverages Docker's layer caching. If source code changes but dependencies don't, the `npm install` step is cached.

---

### Step 3: Build the Docker Image

Build the image with a tag:

```bash
docker build -t sample-nodejs-app .
```

![Build Image](Screenshots/Screenshot%202026-03-16%20111219.png)

The build process:
1. Downloads the `node:18-alpine` base image
2. Sets up the working directory
3. Installs npm dependencies
4. Copies the application source code
5. Tags the final image as `sample-nodejs-app`

---

### Step 4: Run the Container

Start the containerized application:

```bash
docker run -d -p 3000:3000 --name my-node-app sample-nodejs-app
```

Verify the container is running:

```bash
docker ps
```

![Run Container](Screenshots/Screenshot%202026-03-16%20111330.png)

---

### Step 5: Test the Application

Open a browser and navigate to:

```
http://localhost:3000
```

✅ **Result:** The Node.js application is accessible and running inside the Docker container.

---

### Step 6: Cleanup

```bash
# Stop and remove the container
docker stop my-node-app
docker rm my-node-app

# Remove the image (optional)
docker rmi sample-nodejs-app
```

---

## 📊 Summary

| Task | Command | Status |
|---|---|---|
| Clone application | `git clone ...` | ✅ |
| Create Dockerfile | `nano Dockerfile` | ✅ |
| Build Docker image | `docker build -t sample-nodejs-app .` | ✅ |
| Run container | `docker run -d -p 3000:3000 ...` | ✅ |
| Test application | Access `http://localhost:3000` | ✅ |
| Cleanup | Stop, remove container and image | ✅ |

---

## 💡 Key Takeaways

1. A **Dockerfile** is a blueprint for building Docker images — it defines the base image, dependencies, source code, and startup command
2. Using **Alpine-based images** (`node:18-alpine`) significantly reduces image size compared to full images
3. **Layer caching** optimization: copy dependency files before source code to speed up subsequent builds
4. The `-p` flag maps host ports to container ports, making the application accessible externally
5. Always use `.dockerignore` to exclude unnecessary files (e.g., `node_modules`, `.git`) from the build context
6. **EXPOSE** is documentation only — the `-p` flag in `docker run` actually publishes the port
