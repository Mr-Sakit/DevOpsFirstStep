# Lab 1 — File Management Basics using Shell Scripting

## Overview

In this lab, we created a shell script that demonstrates basic file management operations: **creating**, **copying**, **renaming**, **moving**, and **deleting** files and directories. These are among the most common tasks automated with shell scripting in DevOps environments.

---

## Step 1 — Creating the Script

We created a working directory and wrote the script using `nano`:

```bash
mkdir day5-lab1
cd day5-lab1/
touch file_manage.sh
nano file_manage.sh
```

**Script content (`file_manage.sh`):**

```bash
#!/bin/bash
# Lab 1: File Management Basics
# This script creates a directory and file, then copies, renames, moves,
# and deletes them to demonstrate basic file management.

# Variables for directory and file names
WORK_DIR="lab1_test"                # Working directory to create
BACKUP_DIR="lab1_backup"            # Directory for backup copy
FILE_NAME="sample.txt"              # Name of the file to create and manipulate
NEW_NAME="sample_renamed.txt"       # New name for the file after renaming

echo "Creating directory $WORK_DIR ..."
mkdir -p "$WORK_DIR"                # Create the working directory

echo "Creating a sample file in $WORK_DIR ..."
echo "Hello, this is a sample file." > "$WORK_DIR/$FILE_NAME"

echo "Listing files in $WORK_DIR:"
ls -l "$WORK_DIR"                   # List files to confirm creation

echo "Creating backup directory $BACKUP_DIR ..."
mkdir -p "$BACKUP_DIR"              # Create backup directory

echo "Copying $FILE_NAME to backup directory..."
cp "$WORK_DIR/$FILE_NAME" "$BACKUP_DIR/"

echo "Renaming $FILE_NAME to $NEW_NAME ..."
mv "$WORK_DIR/$FILE_NAME" "$WORK_DIR/$NEW_NAME"

echo "Moving $NEW_NAME into a new subdirectory..."
NEW_SUBDIR="$WORK_DIR/subdir"
mkdir -p "$NEW_SUBDIR"              # Create a new subdirectory
mv "$WORK_DIR/$NEW_NAME" "$NEW_SUBDIR/"

echo "Deleting the file in subdirectory..."
rm "$NEW_SUBDIR/$NEW_NAME"          # Delete the file

echo "Cleaning up directories..."
rmdir "$NEW_SUBDIR"                 # Remove the subdirectory
rmdir "$WORK_DIR"                   # Remove the working directory

echo "File operations complete. Backup copy is in $BACKUP_DIR."
```

![file_manage.sh script content in nano editor](Screenshot%202026-02-27%20102941.png)

---

## Step 2 — Running the Script

```bash
chmod +x file_manage.sh
./file_manage.sh
```

**Output:**
```
Creating directory lab1_test ...
Creating a sample file in lab1_test ...
Listing files in lab1_test:
total 4
-rw-rw-r-- 1 mr-sakit mr-sakit 30 Feb 27 06:28 sample.txt
Creating backup directory lab1_backup ...
Copying sample.txt to backup directory...
Renaming sample.txt to sample_renamed.txt ...
Moving sample_renamed.txt into a new subdirectory...
Deleting the file in subdirectory...
Cleaning up directories...
File operations complete. Backup copy is in lab1_backup.
```

---

## Step 3 — Verifying the Results

After running the script, we verified that the backup copy was preserved:

```bash
ls
cd lab1_backup/
ls
cat sample.txt
```

**Output:**
```
file_manage.sh  lab1_backup
sample.txt
Hello, this is a sample file.
```

The working directory (`lab1_test`) was cleaned up, but the backup file (`lab1_backup/sample.txt`) was preserved as expected.

![Script execution and backup verification](Screenshot%202026-02-27%20102906.png)

---

## Key Takeaways

| Command | Description |
|---------|-------------|
| `mkdir -p` | Create directory (no error if exists) |
| `echo "text" > file` | Create file with content (overwrite) |
| `cp src dest` | Copy a file |
| `mv old new` | Rename or move a file |
| `rm file` | Delete a file |
| `rmdir dir` | Remove an empty directory |
| `ls -l` | List files with details |

> **Note:** `rm` and `rmdir` are irreversible — always be cautious when deleting files and directories.
