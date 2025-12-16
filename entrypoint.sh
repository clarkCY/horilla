#!/bin/bash

# --- NEW: Generate the .env file dynamically ---
# This ensures the app gets the real DB details from Docker Compose
echo "Generating .env file from environment variables..."
cat <<EOT > /horilla/.env
DATABASE_URL=$DATABASE_URL
DEBUG=$DEBUG
SECRET_KEY=$SECRET_KEY
ALLOWED_HOSTS=$ALLOWED_HOSTS
CSRF_TRUSTED_ORIGINS=$CSRF_TRUSTED_ORIGINS
TIME_ZONE=$TIME_ZONE
EOT

# --- Wait for Database ---
echo "Waiting for database to be ready..."
while ! python3 -c "import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); result = s.connect_ex(('db', 5432)); exit(result)" > /dev/null 2>&1; do
  echo "Database not ready yet... sleeping 1s"
  sleep 1
done

# --- Run System Checks ---
echo "Running migrations..."
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --noinput

# --- Create Admin User (Ignore error if exists) ---
python3 manage.py createhorillauser --first_name admin --last_name admin --username admin --password admin --email admin@example.com --phone 1234567890 || true

# --- Start the Server ---
echo "Starting Gunicorn..."
exec "$@"