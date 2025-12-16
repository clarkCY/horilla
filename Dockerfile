# 1. Use an official Python runtime based on Debian (Bullseye)
# "Slim" is smaller, but "Bullseye" ensures we have the tools to build C-extensions like psycopg2
FROM python:3.11-slim-bullseye

# 2. Set environment variables
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing pyc files to disc
# PYTHONUNBUFFERED: Ensures logs are flushed immediately (vital for Docker/Railway logs)
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 3. Set the working directory
# We match the path used in your docker-compose volumes
WORKDIR /horilla

# 4. Install system dependencies
# libpq-dev is REQUIRED for psycopg2 (Postgres driver)
# gcc and python3-dev are needed to compile some Python packages
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    libpq-dev \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# 5. Install Python dependencies
# We copy requirements first to leverage Docker cache
COPY requirements.txt /horilla/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# 6. Copy the project code
COPY . /horilla/

# 7. (Optional) Collect Static files
# Un-comment this if you are deploying to production and need static files served
# RUN python horilla/manage.py collectstatic --noinput

# 8. Expose the port (Documentation only)
EXPOSE 8000

# 9. Default Command
# We use the same command as docker-compose, but it's good to have it here as a fallback
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "horilla.wsgi:application"]