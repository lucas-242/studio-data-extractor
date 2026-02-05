---
description: Init project
auto_execution_mode: 1
---

## Step 0 – Ensure docker is running

1. Check if docker is running
2. If not, prompt user to start docker

## Step 1 – Create database

1. Create schemas
```bash
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/init/001_create_schemas.sql    
```

3. Create function `safe_utf8`

```bash
docker exec -i studio_postgres psql -U studio_user -d studio < postgres/functions/safe_utf8.sql    
```

## Step 2 – Create tables

**FOREACH** file in `postgres/init/*.sql` starting from second runs:

```bash
docker exec -i studio_postgres psql -U studio_user -d postgres < postgres/init/{file}.sql    
```

## Step 3 – Create other functions

**FOREACH** file in `postgres/functions/*.sql` runs:

```bash
docker exec -i studio_postgres psql -U studio_user -d postgres < postgres/functions/{file}.sql    
```

## Step 4 – Create triggers

**FOREACH** file in `postgres/triggers/*.sql` runs:

```bash
docker exec -i studio_postgres psql -U studio_user -d postgres < postgres/triggers/{file}.sql    
```

## Step 5 – Run ETL

1. Run `docker compose up --build -d etl`


## Step 6 – Insert Tables Based on new imported data

**FOREACH** file in `postgres/inserts/*.sql` runs:

```bash
docker exec -i studio_postgres psql -U studio_user -d postgres < postgres/inserts/{file}.sql    
```