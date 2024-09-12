#!/bin/bash

# Ensure jq (JSON parser) is installed to read the config file and PostgreSQL is installed
sudo apt-get update
sudo apt-get install -y jq postgresql postgresql-contrib

# Load the password from the config.json file
CONFIG_FILE="config.json"
DB_PASSWORD=$(jq -r '.db_password' $CONFIG_FILE)

if [ -z "$DB_PASSWORD" ]; then
    echo "Error: Password not found in $CONFIG_FILE."
    exit 1
fi

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Use sudo to log in as the PostgreSQL superuser and execute the necessary SQL commands
sudo -u postgres psql << EOF

-- Create the user 'jackson' with the password from config.json, if it doesn't exist
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'jackson') THEN
        CREATE USER jackson WITH PASSWORD '$DB_PASSWORD';
        ALTER USER jackson WITH SUPERUSER;
    END IF;
END
\$\$;

EOF

# Create the 'dreamchain' database owned by 'jackson' if it doesn't exist
sudo -u postgres createdb -O jackson dreamchain

# Create the 'licenses' schema in the 'dreamchain' database
sudo -u postgres psql -d dreamchain << EOF

-- Create the 'licenses' schema if it doesn't exist
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'licenses') THEN
        CREATE SCHEMA licenses;
    END IF;
END
\$\$;

EOF

# Modify the pg_hba.conf file to use md5 authentication for all local connections
PG_HBA_FILE="/etc/postgresql/14/main/pg_hba.conf"  # Adjust version if necessary

# Backup the original pg_hba.conf file
sudo cp $PG_HBA_FILE ${PG_HBA_FILE}.bak

# Replace all instances of 'peer' authentication with 'md5' for local connections
sudo sed -i "s/local\s*all\s*all\s*peer/local   all   all   md5/" $PG_HBA_FILE

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql

# Success message
echo "PostgreSQL installed and configured successfully!"
echo "Admin account 'jackson' created with the password from config.json."
echo "Database 'dreamchain' and schema 'licenses' created."
echo "Authentication method updated to md5 for all users."

# Verify PostgreSQL service status
sudo systemctl status postgresql
