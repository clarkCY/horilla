FROM python:3.10-slim-bullseye

ENV PYTHONUNBUFFERED=1
# These ENV vars are just placeholders now; 
# the real values come from docker-compose -> entrypoint -> .env
ENV DATABASE_URL=""
ENV DEBUG=True
ENV SECRET_KEY=changeme
ENV ALLOWED_HOSTS=*
ENV CSRF_TRUSTED_ORIGINS=
ENV TIME_ZONE=UTC

RUN apt-get update && apt-get install -y libcairo2-dev gcc git

# Clone the repository
RUN git clone https://github.com/clarkCY/horilla.git

WORKDIR /horilla

# REMOVED: git checkout master (Repository uses 'main' by default)
# REMOVED: The old .env.dist creation lines (Moved to entrypoint.sh)

RUN pip install -r requirements.txt

# Make entrypoint executable
RUN chmod +x /horilla/entrypoint.sh && sed -i 's/\r$//' /horilla/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/horilla/entrypoint.sh"]
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "horilla.wsgi:application"]