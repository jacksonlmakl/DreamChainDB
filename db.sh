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

# Modify /etc/postgresql/12/main/postgresql.conf to listen on 0.0.0.0
PG_CONF="/etc/postgresql/12/main/postgresql.conf"

if [ -f "$PG_CONF" ]; then
  sudo sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
  echo "Updated listen_addresses in postgresql.conf"
else
  echo "PostgreSQL configuration file not found!"
  exit 1
fi

# Modify pg_hba.conf to allow connections from any IP
PG_HBA="/etc/postgresql/12/main/pg_hba.conf"

if [ -f "$PG_HBA" ]; then
  sudo bash -c "echo 'host    all             all             0.0.0.0/0               md5' >> $PG_HBA"
  echo "Updated pg_hba.conf to allow connections from any IP"
else
  echo "pg_hba.conf file not found!"
  exit 1
fi

# Restart PostgreSQL to apply the changes
sudo systemctl restart postgresql

# Execute SQL files
sudo -u postgres psql -f db.sql
sudo -u postgres psql -d dreamchain -f schema_table.sql

