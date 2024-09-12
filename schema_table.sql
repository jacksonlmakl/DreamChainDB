-- Connect to the DREAMCHAIN database (this part won't be in the script, you'll run it manually)
-- Create a new schema (optional, but useful for organizing tables)
CREATE SCHEMA IF NOT EXISTS ACCOUNTS;

-- Set the schema as the default for future table creation
SET search_path TO ACCOUNTS;

-- Create a new table for storing licenses
CREATE TABLE LICENSE (
    license_key VARCHAR(100) PRIMARY KEY,
    license_type VARCHAR(50) NOT NULL,
    issued_date DATE DEFAULT CURRENT_DATE,
    expiry_date DATE,
    status VARCHAR(20) NOT NULL
);

