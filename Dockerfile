# Use an official Python runtime as a parent image
FROM python:3.12-slim-bookworm

# Set work directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends pipx \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -u 1000 nonrootuser

# Install poetry as the non-root user
USER 1000
RUN pipx install poetry

# Add poetry to PATH for the non-root user
ENV PATH="/home/nonrootuser/.local/bin:$PATH"

# Copy project files and set ownership
COPY --chown=nonrootuser:nonrootuser /content/pyproject.toml /content/poetry.lock /app/

# Project initialization
RUN poetry install --no-interaction --no-ansi

# Copying the rest of the project files
COPY --chown=nonrootuser:nonrootuser /content/. /app/

# Expose webserver port
# EXPOSE 5000

# Run the webserver
CMD ["poetry", "run", "flask", "run", "-h", "0.0.0.0"]