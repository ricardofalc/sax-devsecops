# Use an official Python runtime as a parent image
FROM python:3.12-slim-bookworm

# Set work directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends pipx \
    && rm -rf /var/lib/apt/lists/*

# Install poetry
RUN pipx install poetry

# Add poetry to PATH
ENV PATH="/root/.local/bin:$PATH"

# Copy only requirements to cache them in docker layer
COPY /content/pyproject.toml /content/poetry.lock /app/

# Project initialization
RUN poetry install --no-interaction --no-ansi

# Copying the project files into the container
COPY /content/. /app/

# Create a non-root user and switch to it
RUN useradd -m -u 1000 nonrootuser
USER nonrootuser

# Expose webserver port
# EXPOSE 5000

# Run the webserver
CMD ["poetry", "run", "flask", "run", "-h", "0.0.0.0"]