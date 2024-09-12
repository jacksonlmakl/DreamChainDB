#!/bin/bash

# Load environment variables from config.env
if [ -f config.env ]; then
  export $(grep -v '^#' config.env | xargs)
else
  echo "config.env file not found!"
  exit 1
fi

# Ensure PG_PASSWORD is set
if [ -z "$PG_PASSWORD" ]; then
  echo "PG_PASSWORD is not set in config.env"
  exit 1
fi

# Update package list and install PostgreSQL
sudo apt update
sudo apt install -y postgresql postgresql-contrib

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Set password for postgres user
sudo -u postgres psql -c "ALTER USER postgres PASSWORD '$PG_PASSWORD';"

# Ensure db.sql file exists
if [ ! -f db.sql ]; then
  echo "db.sql file not found!"
  exit 1
fi



sudo -u postgres psql -f db.sql
sudo -u postgres psql -d dreamchain -f schema_table.sql
