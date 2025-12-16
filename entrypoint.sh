#!/bin/bash

# 1. Generate .env file at runtime (Fixes the environment variable issue)
#    This ensures that whatever vars you pass to 'docker run' are actually used.
echo "Generating .env file..."
cat <<EOT > .env
DATABASE_URL=$DATABASE_URL
DEBUG=$DEBUG
SECRET_KEY=$SECRET_KEY
ALLOWED_HOSTS=$ALLOWED_HOSTS
CSRF_TRUSTED_ORIGINS=$CSRF_TRUSTED_ORIGINS
TIME_ZONE=$TIME_ZONE
EOT

# 2. Actually wait for the database (Postgres default port 5432)
#    We use a small Python snippet to check the connection.
echo "Waiting for database to be ready..."
while ! python3 -c "import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); result = s.connect_ex(('db', 5432)); exit(result)" > /dev/null 2>&1; do
  echo "Database not ready yet... sleeping 1s"
  sleep 1
done
echo "Database is ready!"

# 3. Run Migrations
python3 manage.py makemigrations
python3 manage.py migrate

# 4. Collect Static files
python3 manage.py collectstatic --noinput

# 5. Create Superuser (Safe Mode)
#    We use '|| true' to prevent the script from crashing if the user already exists.
echo "Creating default admin user..."
python3 manage.py createhorillauser --first_name admin --last_name admin --username admin --password admin --email admin@example.com --phone 1234567890 || true

# 6. Hand off control to the Dockerfile CMD
#    This allows you to choose between 'runserver' (dev) or 'gunicorn' (prod) 
#    just by changing the Dockerfile CMD, without editing this script.
exec "$@"