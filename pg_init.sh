#!/bin/bash

# Install PostgreSQL and necessary components
sudo apt-get install -y postgresql postgresql-contrib

# Load environment variables from config.env
if [ -f config.env ]; then
  export $(grep -v '^#' config.env | xargs)
else
  echo "config.env file not found!"
  exit 1
fi

# Check if environment variables are set
if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
  echo "Please set DB_USER, DB_PASSWORD, and DB_NAME environment variables."
  exit 1
fi

# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create the user with superuser privileges
sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD' SUPERUSER;"

# Create the database with the user as the owner
sudo -u postgres psql -c "CREATE DATABASE ""$DB_NAME"";"

# Create the schema owned by the new user
sudo -u postgres psql  -d $DB_NAME -c "CREATE SCHEMA ""LICENSE"";"

# Restart PostgreSQL service to apply changes
sudo systemctl restart postgresql

# Show PostgreSQL service status
sudo systemctl status postgresql

