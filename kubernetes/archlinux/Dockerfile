# Use the Arch Linux latest image from the Arch Linux repository
FROM archlinux:latest

# Update package database and install python-pip
RUN pacman -Syu --noconfirm python-pip

# Create virtual environment
RUN python -m venv /app/venv

# Activate virtual environment
ENV PATH="/app/venv/bin:$PATH"

# Copy the app directory and start.sh into the Docker image
WORKDIR /app
COPY ./app /app

# Get the latest .whl file and install the application
RUN pip install $(ls -Art /app/*.whl | tail -n 1)

# Give execution rights to the start.sh script
RUN chmod +x /app/start.sh
