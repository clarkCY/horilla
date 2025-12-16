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

# Clone the repository (automatically checks out 'main')
RUN git clone https://github.com/clarkCY/horilla.git

WORKDIR /horilla

# 'RUN git checkout master' REMOVED

RUN pip install -r requirements.txt

# Ensure entrypoint is executable
RUN chmod +x /horilla/entrypoint.sh && sed -i 's/\r$//' /horilla/entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/horilla/entrypoint.sh"]

# Default command
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "horilla.wsgi:application"]