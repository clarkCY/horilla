# 1. Use an official Python runtime (Bullseye is stable for Postgres drivers)
FROM python:3.11-slim-bullseye

# 2. Set environment variables to prevent python buffering logs
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# 3. Set work directory
WORKDIR /horilla

# 4. Install system dependencies
# netcat: used to check network connection
# libpq-dev & gcc: used to build psycopg2
RUN apt-get update && apt-get install -y \
    gcc \
    python3-dev \
    libpq-dev \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# 5. Install Python dependencies
COPY requirements.txt /horilla/
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# 6. Copy project code
COPY . /horilla/

# 7. Copy and setup Entrypoint
COPY entrypoint.sh /entrypoint.sh
# Make the script executable (CRITICAL STEP)
RUN chmod +x /entrypoint.sh

# 8. Expose port (Documentation only)
EXPOSE 8000

# 9. Set the Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# 10. Default Start Command
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "horilla.wsgi:application"]