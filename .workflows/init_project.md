---
description: Initialize Studio Project Database and runs ETL
auto_execution_mode: 1
---

# Studio Project Initialization Workflow

This workflow sets up the complete database structure and initializes the ETL system for the Studio project.

## Prerequisites

- Docker and Docker Compose installed
- Docker daemon running

---

## Step 0 – Verify Docker Status

**Objective**: Ensure Docker is available and running

1. Check if Docker daemon is running
2. If not running, prompt user to start Docker with:
   ```bash
   docker info
   ```

---

## Step 1 – Create Database Schema

**Objective**: Initialize the database schema structure

Execute the schema creation script:
```bash
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/init/001_create_schemas.sql
```

---

## Step 2 – Create Database Functions

**Objective**: Set up utility functions for data processing

Install the `safe_utf8` function:
```bash
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/functions/safe_utf8.sql
```

---

## Step 3 – Create Database Tables

**Objective**: Create all tables and views in the correct order

Execute all remaining initialization scripts in order:
```bash
# Create raw tables
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/init/002_create_raw_gendo_report_304.sql

# Create staging views
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/init/003_create_staging_views.sql

# Create dimension tables
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/init/004_create_dim_tables.sql

# Create fact tables
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/init/005_create_fact_tables.sql
```

---

## Step 4 – Load Initial Data

**Objective**: Populate dimension tables with initial data

1. Check if `postgres/inserts/` directory contains SQL files
2. If there is only `000_insert_dim_professionals_from_raw_gendo_repor.sql` files found, skip to Step 5
3. If other files exist, execute them in order ignoring `000_insert_dim_professionals_from_raw_gendo_repor.sql`:

**FOREACH** file in `postgres/init/*.sql` that is not `000_insert_dim_professionals_from_raw_gendo_repor.sql`:

```bash
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/inserts/{{file}}.sql
```

---

## Step 5 – Initialize ETL System

**Objective**: Start the ETL pipeline for data processing

1. If no other files other than `000_insert_dim_professionals_from_raw_gendo_repor.sql` was found in Step 4, prompt user:
   - "No initial data found. Would you like to run the ETL system anyway? It can load facts without professionals (y/n)"
   
2. If user confirms or if data was loaded, start ETL:
```bash
docker compose up --build -d etl
```

3. Verify ETL is running:
```bash
docker compose logs -f etl
```

---

## ✅ Completion Checklist

- [ ] Docker is running
- [ ] Database schema created
- [ ] Utility functions installed  
- [ ] All tables and views created
- [ ] Initial data loaded (if available)
- [ ] ETL system started (if requested)

---

## 🔧 Troubleshooting

**Common Issues:**
- **Docker not running**: Start Docker Desktop or run `sudo systemctl start docker`
- **Connection refused**: Verify PostgreSQL container is running with `docker ps`
- **SQL errors**: Check PostgreSQL logs with `docker logs studio_postgres`

**Verification Commands:**
```bash
# Check database structure
docker exec -i studio_postgres psql -U studio_user -d studio -c "\dt"

# Check ETL status
docker compose ps etl
```
