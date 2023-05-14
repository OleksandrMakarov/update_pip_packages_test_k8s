# Use the latest version of Ubuntu
FROM ubuntu:latest

# Update system and install python3 and pip
RUN apt update && apt install -y python3 python3-pip

# Copy the app directory and start.sh into the Docker image
COPY ./app /app

# Get the latest .whl file and install the application
RUN pip install $(ls -Art /app/*.whl | tail -n 1)

# Give execution rights to the start.sh script
RUN chmod +x /app/start.sh
