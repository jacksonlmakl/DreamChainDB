#!/bin/bash

sudo apt-get update
sudo apt-get install -y  postgresql postgresql-contrib

# Load the configuration from the config.env file
CONFIG_FILE="config.env"

# Ensure config.env file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found."
    exit 1
fi

source "$CONFIG_FILE"


# Ensure DB_USER, DB_PASSWORD, and DB_NAME are present
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
    echo "Error: One or more required environment variables (DB_USER, DB_PASSWORD, DB_NAME) are missing in $CONFIG_FILE."
    exit 1
fi

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo -u postgres psql <<EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
EOF

sudo -u postgres psql <<EOF
CREATE DATABASE "$DB_NAME" OWNER $DB_USER;
EOF

sudo -u postgres psql <<EOF
CREATE SCHEMA "$DB_NAME"."LICENSE";
EOF

sudo -u postgres psql <<EOF
GRANT OWNERSHIP ON SCHEMA "$DB_NAME"."LICENSE" TO USER $DB_USER;
EOF

sudo systemctl restart postgresql
sudo systemctl status postgresql

