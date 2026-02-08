-- This table is used to store manual expense entries
CREATE TABLE dw.fact_expenses (
    expense_id SERIAL PRIMARY KEY,
    payment_date DATE NOT NULL,          
    reference_month DATE NOT NULL,        
    description TEXT,
    category TEXT,                       
    expense_type TEXT CHECK (expense_type IN ('Fixo', 'Variável')),
    payment_method TEXT CHECK (payment_method IN ('Dinheiro', 'PIX', 'Crédito', 'Débito')),
    installments INT DEFAULT NULL,          
    current_installment INT DEFAULT NULL,
    amount NUMERIC(10,2) NOT NULL
);

ALTER TABLE dw.fact_expenses 
ADD CONSTRAINT check_installments 
CHECK (
    (payment_method = 'Crédito') OR 
    (installments IS NULL AND current_installment IS NULL)
);

-- This table is used to save the fact sales data
CREATE TABLE dw.fact_sales (
    source_id VARCHAR(64),
    service_date DATE,
    service_month DATE,
    weekday_number INTEGER,
    order_code VARCHAR(50),
    professional_id INTEGER,
    professional_name VARCHAR(100),
    service_id INTEGER,
    service_name VARCHAR(100),
    category VARCHAR(50),
    gross_revenue NUMERIC(10,2),
    commission_percent NUMERIC(5,2),
    commission_value NUMERIC(10,2),
    service_avg_cost NUMERIC(10,2),
    service_duration INTERVAL,
    contribution_margin NUMERIC(10,2),
    payment_method VARCHAR(50),
    client_name VARCHAR(100),
    client_phone VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    unique_hash VARCHAR(64) UNIQUE
);
