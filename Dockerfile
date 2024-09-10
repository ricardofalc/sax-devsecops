# Use an official Python runtime as a parent image
FROM python:3.12-slim-bookworm

# Set work directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends pipx \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN /usr/bin/pipx install poetry

# Create a non-root user
RUN useradd -m -u 1000 nonrootuser

# Copy only requirements to cache them in docker layer
COPY --chown=nonrootuser:nonrootuser /content/pyproject.toml /content/poetry.lock /app/

# Project initialization
RUN /root/.local/bin/poetry install --no-interaction --no-ansi

# Copying the project files into the container
COPY --chown=nonrootuser:nonrootuser /content/. /app/

# Create the log file and set permissions
RUN touch /app/access.log && chown nonrootuser:nonrootuser /app/access.log

# Change to non-root user
USER 1000

# Expose webserver port
# EXPOSE 5000

# Run the webserver
CMD ["/root/.local/bin/poetry", "run", "flask", "run", "-h", "0.0.0.0"]