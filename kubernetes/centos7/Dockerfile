# Use the CentOS 7 image from the centos repository
FROM centos:centos7

# Install necessary utilities
RUN yum install -y wget gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

# Download Python source code
RUN wget https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz && \
    tar -xzf Python-3.8.1.tgz

# Install Python
WORKDIR /Python-3.8.1
RUN ./configure --enable-optimizations && \
    make altinstall

# Create a symbolic link to use the python3 command
RUN ln -s /usr/local/bin/python3.8 /usr/bin/python3

# Install pip
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python3 get-pip.py

# Copy the app directory and start.sh into the Docker image
WORKDIR /app
COPY ./app /app

# Get the latest .whl file and install the application
RUN pip install $(ls -Art /app/*.whl | tail -n 1)

# Give execution rights to the start.sh script
RUN chmod +x /app/start.sh
