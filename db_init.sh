#!/bin/bash

sudo apt-get update
sudo apt-get install -y  postgresql postgresql-contrib

# Load the configuration from the config.env file
CONFIG_FILE="config.env"
source "config.env"


# Start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo -u postgres psql <<EOF
CREATE USER $DB_USER WITH PASSWORD $DB_PASSWORD;
EOF

sudo -i postgres psql <<EOF
ALTER USER $DB_USER WITH SUPERUSER;
EOF


sudo -u postgres psql <<EOF
CREATE DATABASE $DB_NAME OWNER $DB_USER;
EOF


sudo -u postgres psql <<EOF
CREATE SCHEMA LICENSE OWNER $DB_USER;
EOF


sudo systemctl restart postgresql
sudo systemctl status postgresql

