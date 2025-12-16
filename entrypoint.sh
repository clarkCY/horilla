#!/bin/sh

# Stop the script if any command fails
set -e

echo "Entrypoint script is running..."

# 1. Wait for Database
# We check if DATABASE_HOST is set. If so, we wait for it to be ready.
if [ -n "$DATABASE_HOST" ]; then
    echo "Waiting for PostgreSQL at $DATABASE_HOST:$DATABASE_PORT..."

    # 'nc -z' checks if the port is open. We loop until it is.
    while ! nc -z $DATABASE_HOST $DATABASE_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started!"
fi

# 2. Run Migrations
# This commands creates tables if missing, or updates them if changed.
echo "Applying database migrations..."
python manage.py migrate

# 3. (Optional) Collect Static Files
# Uncomment if your static files (CSS/JS) are missing in production
# echo "Collecting static files..."
# python manage.py collectstatic --noinput

# 4. Start the Server
# 'exec' replaces the shell with the command from Docker (Gunicorn)
echo "Starting application..."
exec "$@"