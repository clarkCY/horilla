#!/bin/bash

# 1. Generate .env file from environment variables
echo "Generating .env file..."
cat <<EOT > /horilla/.env
DATABASE_URL=$DATABASE_URL
DEBUG=$DEBUG
SECRET_KEY=$SECRET_KEY
ALLOWED_HOSTS=$ALLOWED_HOSTS
CSRF_TRUSTED_ORIGINS=$CSRF_TRUSTED_ORIGINS
TIME_ZONE=$TIME_ZONE
EOT

# 2. Wait for Database (Universal Method)
#    We try to connect using Django's built-in connection handler. 
#    This works regardless of whether the host is 'db' or a Railway URL.
echo "Waiting for database..."
while ! python3 -c "import django; django.setup(); from django.db import connections; from django.db.utils import OperationalError; try: connections['default'].cursor(); except OperationalError: exit(1)" > /dev/null 2>&1; do
  echo "Database not ready yet... sleeping 1s"
  sleep 1
done
echo "Database is ready!"

# 3. Run Migrations
echo "Running migrations..."
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --noinput

# 4. Create Admin User (Safe Mode)
#    This might print an error if user exists, but '|| true' keeps the script running.
echo "Creating admin user..."
python3 manage.py createhorillauser --first_name admin --last_name admin --username admin --password admin --email admin@example.com --phone 1234567890 || true

# 5. Start Server
echo "Starting Server..."
exec "$@"