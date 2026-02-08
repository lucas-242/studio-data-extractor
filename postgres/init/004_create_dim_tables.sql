-- Create dimension table for professionals
CREATE TABLE IF NOT EXISTS dw.dim_professionals (
    professional_id SERIAL PRIMARY KEY,
    professional_name TEXT UNIQUE NOT NULL,
    contract_model TEXT CHECK (contract_model IN ('PJ', 'CLT', 'Sócio')),
    monthly_fixed_cost NUMERIC(10,2) DEFAULT NULL,
    fixed_commission_rate DECIMAL(5,2) DEFAULT NULL,
    hire_date DATE DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE
);

-- Create dimension tables for services and their costs
CREATE TABLE IF NOT EXISTS dw.dim_services (
    service_id SERIAL PRIMARY KEY,
    service_name TEXT UNIQUE NOT NULL,
    base_category TEXT,
    base_price NUMERIC(10,2) DEFAULT 0,  -- Current table price
    avg_cost NUMERIC(10,2) DEFAULT 0,    -- Average cost for to realize service
    duration INTERVAL,
    default_commission_percentage NUMERIC(5,2) DEFAULT NULL,  -- Default commission for this service
    is_active BOOLEAN DEFAULT TRUE
);

-- Create dimension table for commission rules mapping which professional gets for each service
CREATE TABLE IF NOT EXISTS dw.dim_commission_exceptions (
    professional_id INTEGER REFERENCES dw.dim_professionals(professional_id),
    service_id INTEGER REFERENCES dw.dim_services(service_id),
    commission_percentage NUMERIC(5,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (professional_id, service_id)
);