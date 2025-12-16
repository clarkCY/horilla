FROM python:3.10-slim-bullseye

ENV PYTHONUNBUFFERED=1
ENV DATABASE_URL=""
ENV DEBUG=True
ENV SECRET_KEY=changeme
ENV ALLOWED_HOSTS=*
ENV CSRF_TRUSTED_ORIGINS=
ENV TIME_ZONE=UTC

# Install system dependencies
RUN apt-get update && apt-get install -y libcairo2-dev gcc git

# Clone the repository
RUN git clone https://github.com/clarkCY/horilla.git

WORKDIR /horilla

# Ensure we are on the correct branch
RUN git checkout master

RUN pip install -r requirements.txt

# Make entrypoint executable
RUN chmod +x /horilla/entrypoint.sh && sed -i 's/\r$//' /horilla/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/horilla/entrypoint.sh"]

# UPDATED CMD: We now use Gunicorn here. 
# Because the entrypoint uses 'exec "$@"', this command will be executed 
# after migrations and user creation are finished.
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "horilla.wsgi:application"]