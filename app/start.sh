#!/bin/bash

# Check for /etc/os-release
if [ -f /etc/os-release ]; then
    . /etc/os-release
    os_name=$ID
    os_version=$VERSION_ID
else
    # Fallback for systems without /etc/os-release
    os_name=$(uname -s)
fi

{
    update-pip-packages -v
    update-pip-packages --version
    update-pip-packages -h
    update-pip-packages --help
    update-pip-packages --app
    update-pip-packages --pip
} &>"/hostPath/${os_name}-${os_version}_$(date +%d%m%Y_%H%M%S).log"
