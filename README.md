# Studio Analytics Data Warehouse

An end-to-end data pipeline built to transform Gendo legacy reports into actionable business intelligence.

## 1. Project Overview

This project automates the extraction, transformation, and loading (ETL) of salon management data. It employs a **Medallion Architecture** (Raw -> Staging -> Data Warehouse) to ensure data integrity and provide a "Single Source of Truth" for financial and operational KPIs.

## 2. Architecture & Data Flow

### Data Layers

* **Raw Layer (`raw`)**: Ingests original CSV files. Uses SHA-256 hashing for idempotency, ensuring no duplicate records.
* **Staging Layer (`staging`)**: Cleans data types, handles `Latin-1` encoding artifacts, and normalizes categorical values (e.g., unifying payment methods).
* **Data Warehouse (`dw`)**: A Star Schema design:
* **Dimensions**: `dim_services` (prices, costs, durations), `dim_professionals` (contract types), and `dim_commission_rules`.
* **Fact View**: `fact_sales` provides a unified view of revenue, commissions, and margins.



### Commission Waterfall Logic

To handle complex payroll scenarios, the system implements a hierarchical commission calculation:

1. **Level 1 (Override)**: Individual professional-service rules in `dim_commission_rules`.
2. **Level 2 (Default)**: Global service commission defined in `dim_services`.
3. **Level 3 (Fallback)**: Zero.

This is executed via SQL `COALESCE` within the `fact_sales` view for real-time accuracy.

## 3. Tech Stack

* **Database**: PostgreSQL 15
* **Language**: Python 3.9+
* **Infrastructure**: Docker & Docker Compose
* **BI Tool**: Metabase

## 4. Infrastructure (Docker)

The project is fully containerized to ensure consistency across development and production environments.

### Services

* **`studio_postrgres`**: PostgreSQL instance with persistent volume storage.
* **`studio_metabase`**: Metabase instance to run the BI tool.
* **`studio_etl`**: Python environment configured to run ingestion scripts.

### Deployment Commands

```bash
# Build and start the containers
docker-compose up -d --build

# Import Gendo data
docker-compose up -d --build etl

```

## 5. ETL Specifications

### Encoding & Formatting

* **Encoding**: Scripts use `latin-1` to decode legacy Brazilian CSV exports (handling characters like `ó`, `ã`, `ç`).
* **Upsert Logic**: Uses `INSERT ... ON CONFLICT DO UPDATE` to allow re-running scripts without data duplication.
* **Duration Parsing**: Converts human-readable strings (e.g., `2h30min`) into PostgreSQL `INTERVAL` types for time-based productivity analysis.

## 6. Database Automations

### Professional Onboarding Trigger

The system includes a PL/pgSQL trigger `trg_new_professional_commissions`.

* **Action**: When a new professional is inserted into `dw.dim_professionals`, it automatically populates their commission table based on the default values in `dw.dim_services`.

---

## 7. Key KPIs available in Metabase

* **Contribution Margin**: Revenue minus variable costs and commissions.
* **Productivity**: Revenue generated per hour of service duration.
* **Payment Split**: Distribution of revenue by method (Credit, Debit, Pix).

## 8. Environment Configuration

Before running the project, create a `.env` file in the root directory with the following variables:

```bash
# PostgreSQL Database Configuration
POSTGRES_DB=db_name
POSTGRES_USER=user_name
POSTGRES_PASSWORD=your_password_here
POSTGRES_PORT=5432
POSTGRES_HOST=postgres

# CSV Data Paths (optional - defaults shown)
GENDO_CSV_SERVICES_PATH=/data/gendo/services
GENDO_CSV_304_PATH=/data/gendo/report-304
```

**Important**: 
- The CSV paths should match the volume mount points in `docker-compose.yml`
- These variables are used by both the ETL scripts and the Docker services

## 9. Initialize Project

Once the project is cloned, docker is running, and the `.env` file is configured, run the following workflow to initialize the project:

```bash
./.workflows/init_project.md
```