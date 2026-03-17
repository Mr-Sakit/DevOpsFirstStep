# Lab 1: Deploy a PostgreSQL Database Using Docker

## 📋 Overview

This lab demonstrates how to deploy and manage a **PostgreSQL 16** database using Docker containers. It covers pulling the official Postgres image, running a containerized database with persistent storage using Docker volumes, creating tables, inserting and querying data, and verifying data persistence across container restarts. Additionally, the lab explores bind mounts, initialization scripts, backup/restore operations, environment variable management with `.env` files, and proper cleanup procedures.

---

## 🎯 Objectives

- Pull the official PostgreSQL Docker image
- Create and use Docker volumes for persistent data storage
- Run a PostgreSQL container with proper configuration
- Create databases, tables, and perform CRUD operations
- Test data persistence by stopping and restarting containers
- Use bind mounts and initialization scripts (`initdb`)
- Perform database backup and restore operations
- Manage environment variables using `.env` files
- Clean up containers, volumes, and images

---

## 🔧 Prerequisites

| Requirement | Details |
|---|---|
| **Docker** | Installed and running on the host machine |
| **Terminal** | Bash/Zsh terminal with Docker CLI access |
| **OS** | Linux (Ubuntu recommended) / WSL on Windows |

---

## 📝 Lab Steps

### Step 1: Pull the PostgreSQL Docker Image

The official PostgreSQL image (version 16) is pulled from Docker Hub:

```bash
docker pull postgres:16
```

![Pull PostgreSQL Image](Screenshots/Screenshot%202026-03-17%20091251.png)

> **Note:** Docker Hub hosts official images for most popular databases. Using a specific version tag (`:16`) ensures consistency across environments.

---

### Step 2: Create a Docker Volume for Persistent Storage

A named volume is created to ensure database data persists even when the container is removed:

```bash
docker volume create pgdata
```

This volume will be mounted to the PostgreSQL data directory inside the container.

> **Why Volumes?** Without a volume, all data stored inside the container would be lost when the container is removed. Docker volumes provide a reliable way to persist data independently from the container lifecycle.

---

### Step 3: Run the PostgreSQL Container

The PostgreSQL container is started with the following command:

```bash
docker run -d \
  --name my-postgres \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret123 \
  -e POSTGRES_DB=myappdb \
  -v pgdata:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:16
```

![Run PostgreSQL Container](Screenshots/Screenshot%202026-03-17%20091306.png)

**Parameter Breakdown:**

| Flag | Purpose |
|---|---|
| `-d` | Run in detached (background) mode |
| `--name my-postgres` | Assign a custom container name |
| `-e POSTGRES_USER` | Set the database superuser username |
| `-e POSTGRES_PASSWORD` | Set the superuser password |
| `-e POSTGRES_DB` | Create an initial database on startup |
| `-v pgdata:/var/lib/postgresql/data` | Mount the volume for data persistence |
| `-p 5432:5432` | Map host port 5432 to container port 5432 |

---

### Step 4: Connect to the Database and Create a Table

Connect to the running PostgreSQL container using `psql`:

```bash
docker exec -it my-postgres psql -U admin -d myappdb
```

Once inside the `psql` shell, create a table and insert data:

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO users (name, email) VALUES ('Sakit', 'sakit@example.com');
INSERT INTO users (name, email) VALUES ('Azure', 'azure@devops.com');

SELECT * FROM users;
```

![Create Table and Query](Screenshots/Screenshot%202026-03-17%20091344.png)

---

### Step 5: Verify Data Persistence

To prove that data survives container restarts, stop and restart the container:

```bash
docker stop my-postgres
docker start my-postgres
docker exec -it my-postgres psql -U admin -d myappdb -c "SELECT * FROM users;"
```

![Data Persistence Test](Screenshots/Screenshot%202026-03-17%20091409.png)

✅ **Result:** The data is still intact after the container restart, confirming that the Docker volume successfully preserves the data.

---

### Step 6: Using Bind Mounts for Initialization Scripts

Bind mounts allow you to map a host directory directly into the container. This is useful for providing initialization SQL scripts:

```bash
docker run -d \
  --name pg-with-init \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=secret123 \
  -e POSTGRES_DB=initdb_test \
  -v ./init-scripts:/docker-entrypoint-initdb.d \
  -p 5433:5432 \
  postgres:16
```

![Bind Mounts and Init Scripts](Screenshots/Screenshot%202026-03-17%20091534.png)

> **How it works:** Any `.sql` or `.sh` files placed in the `/docker-entrypoint-initdb.d` directory inside the container are automatically executed when the database is initialized for the first time.

---

### Step 7: Database Backup and Restore

#### Backup:

```bash
docker exec my-postgres pg_dump -U admin myappdb > backup.sql
```

#### Restore:

```bash
cat backup.sql | docker exec -i my-postgres psql -U admin -d myappdb
```

![Backup and Restore](Screenshots/Screenshot%202026-03-17%20091607.png)

> **Best Practice:** Regular backups are crucial in production environments. Using `pg_dump` provides a logical backup that can be restored on any PostgreSQL instance.

---

### Step 8: Environment Variables with .env File

Instead of passing environment variables directly in the `docker run` command, you can use a `.env` file:

```bash
# .env file content
POSTGRES_USER=admin
POSTGRES_PASSWORD=secret123
POSTGRES_DB=myappdb
```

```bash
docker run -d \
  --name pg-env \
  --env-file .env \
  -v pgdata:/var/lib/postgresql/data \
  -p 5434:5432 \
  postgres:16
```

![Environment File](Screenshots/Screenshot%202026-03-17%20091644.png)

> **Security Tip:** Using `.env` files keeps sensitive credentials out of your command history and makes configuration management easier.

---

### Step 9: Cleanup

After completing the lab, clean up all resources:

```bash
# Stop and remove containers
docker stop my-postgres pg-with-init pg-env
docker rm my-postgres pg-with-init pg-env

# Remove the volume
docker volume rm pgdata

# Optionally remove the image
docker rmi postgres:16
```

![Cleanup](Screenshots/Screenshot%202026-03-17%20091852.png)

---

## 📊 Summary

| Task | Command | Status |
|---|---|---|
| Pull PostgreSQL image | `docker pull postgres:16` | ✅ |
| Create Docker volume | `docker volume create pgdata` | ✅ |
| Run PostgreSQL container | `docker run -d --name my-postgres ...` | ✅ |
| Create table and insert data | `CREATE TABLE users ...` | ✅ |
| Verify data persistence | Stop/Start container and query | ✅ |
| Bind mount init scripts | `docker run -v ./init-scripts:...` | ✅ |
| Backup and restore | `pg_dump` / `psql` restore | ✅ |
| Use .env file | `docker run --env-file .env ...` | ✅ |
| Cleanup | Remove containers, volumes, images | ✅ |

---

## 💡 Key Takeaways

1. **Docker Volumes** are essential for persisting data across container lifecycles
2. **Bind Mounts** provide a convenient way to inject initialization scripts
3. **pg_dump/psql** offer reliable backup and restore capabilities for PostgreSQL
4. **Environment files (.env)** improve security and configuration management
5. **Named containers** make management and orchestration easier
6. Always **clean up resources** after lab exercises to free up disk space
