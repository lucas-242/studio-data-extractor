CREATE TABLE IF NOT EXISTS raw.gendo_report_304 (
  id BIGSERIAL PRIMARY KEY,

  service_date DATE,
  order_code TEXT,

  service_name TEXT,
  category TEXT,

  quantity INTEGER,
  unit_price NUMERIC(10,2),
  total_amount NUMERIC(10,2),
  balance NUMERIC(10,2),

  professional_name TEXT,

  client_name TEXT,
  client_cpf TEXT,
  client_email TEXT,
  client_phone TEXT,

  payment_method TEXT,

  source_report TEXT NOT NULL DEFAULT '304',
  extracted_at TIMESTAMP NOT NULL DEFAULT now(),

  unique_hash TEXT NOT NULL
);


CREATE UNIQUE INDEX IF NOT EXISTS idx_gendo_304_unique_hash
ON raw.gendo_report_304 (unique_hash);
