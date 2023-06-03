# Use the CentOS 9 image from the centos repository
FROM quay.io/centos/centos:stream9

# Install pip
RUN dnf install -y python3-pip

# Copy the app directory and start.sh into the Docker image
WORKDIR /app
COPY ./app /app

# Get the latest .whl file and install the application
RUN pip3 install $(ls -Art /app/*.whl | tail -n 1)

# Give execution rights to the start.sh script
RUN chmod +x /app/start.sh
