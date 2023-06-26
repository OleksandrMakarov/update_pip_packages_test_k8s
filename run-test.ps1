<#
.SYNOPSIS
    A script to build Docker images and run Kubernetes jobs for application testing in various Linux distributions.

.DESCRIPTION
    This script allows you to build Docker images and run Kubernetes jobs for testing in different Linux distributions,
    such as Ubuntu, CentOS 7, CentOS 9, Fedora, Arch Linux, and openSUSE. It supports running tests for individual 
    distributions as well as running tests for all supported distributions.

.PARAMETER ubuntu
    Specifies that the test should be run for Ubuntu.

.PARAMETER centos7
    Specifies that the test should be run for CentOS 7.

.PARAMETER centos9
    Specifies that the test should be run for CentOS 9.

.PARAMETER fedora
    Specifies that the test should be run for Fedora.

.PARAMETER archlinux
    Specifies that the test should be run for Arch Linux.

.PARAMETER opensuse
    Specifies that the test should be run for openSUSE.

.PARAMETER all
    Specifies that the test should be run for all supported Linux distributions.

.PARAMETER help
    Displays the help message.

.EXAMPLE
    .\run-test.ps1 -ubuntu

    This example runs the test for Ubuntu.

.EXAMPLE
    .\run-test.ps1 -all

    This example runs the test for all supported Linux distributions.

.NOTES
    This script requires minikube, kubectl, and Docker to be installed.
    It also assumes that the Kubernetes configuration files and Dockerfiles are located in a specific directory structure.
#>

param (
    [switch]$ubuntu,
    [switch]$centos7,
    [switch]$centos9,
    [switch]$fedora,
    [switch]$archlinux,
    [switch]$opensuse,
    [switch]$all,
    [switch]$help
)

function Show-Help {
    @"
Usage: .\run-test.ps1 [options]

Options:
    -ubuntu     Run the test for Ubuntu.
    -centos7    Run the test for CentOS 7.
    -centos9    Run the test for CentOS 9.
    -fedora     Run the test for Fedora.
    -archlinux  Run the test for Arch Linux.
    -opensuse   Run the test for openSUSE.
    -all        Run the test for all containers.
    -help       Show this help message.
"@
}

if ($help) {
    Show-Help
    exit
}

if (!$ubuntu -and !$centos7 -and !$centos9 -and !$fedora -and !$archlinux -and !$opensuse -and !$all) {
    Write-Host "No options specified. Run .\run-test.ps1 -help for usage instructions."
    exit
}

# Check if minikube is already running
if ($null -eq (minikube status | Select-String -Pattern "host: Running")) {
    Write-Host "Starting minikube..."
    minikube start
    Write-Host "Waiting for minikube and local registry to start up..."
    Start-Sleep -Seconds 60
}
else {
    Write-Host "Minikube is already running."
}

# Navigate to the root directory of the project
Set-Location -Path "D:\Work\Git_repos\update_pip_packages_test_k8s"

# Use Docker daemon inside Minikube
minikube docker-env | Invoke-Expression

if ($ubuntu -or $all) {
    # Delete Job if it exists
    if ($null -ne (kubectl get jobs | Select-String -Pattern "ubuntu-job")) {
        Write-Host "Deleting existing ubuntu-job..."
        kubectl delete job ubuntu-job
    }

    # Build Docker image
    Write-Host "Building Docker image for Ubuntu..."
    docker build -t localhost:5000/ubuntu-app:latest -f ./kubernetes/ubuntu/Dockerfile .

    # Push Docker image to the registry
    Write-Host "Pushing Docker image for Ubuntu to registry..."
    docker push localhost:5000/ubuntu-app:latest

    # Apply Kubernetes Job
    Write-Host "Applying Kubernetes job for Ubuntu..."
    kubectl apply -f ./kubernetes/ubuntu/job.yaml
}

if ($centos7 -or $all) {
    if ($null -ne (kubectl get jobs | Select-String -Pattern "centos7-job")) {
        Write-Host "Deleting existing centos7-job..."
        kubectl delete job centos7-job
    }

    Write-Host "Building Docker image for CentOS 7..."
    docker build -t localhost:5000/centos7-app:latest -f ./kubernetes/centos7/Dockerfile .

    Write-Host "Pushing Docker image for CentOS 7 to registry..."
    docker push localhost:5000/centos7-app:latest

    Write-Host "Applying Kubernetes job for CentOS 7..."
    kubectl apply -f ./kubernetes/centos7/job.yaml
}

if ($centos9 -or $all) {
    if ($null -ne (kubectl get jobs | Select-String -Pattern "centos9-job")) {
        Write-Host "Deleting existing centos9-job..."
        kubectl delete job centos9-job
    }

    Write-Host "Building Docker image for CentOS 9..."
    docker build -t localhost:5000/centos9-app:latest -f ./kubernetes/centos9/Dockerfile .

    Write-Host "Pushing Docker image for CentOS 9 to registry..."
    docker push localhost:5000/centos9-app:latest

    Write-Host "Applying Kubernetes job for CentOS 9..."
    kubectl apply -f ./kubernetes/centos9/job.yaml
}

if ($fedora -or $all) {
    if ($null -ne (kubectl get jobs | Select-String -Pattern "fedora-job")) {
        Write-Host "Deleting existing fedora-job..."
        kubectl delete job fedora-job
    }

    Write-Host "Building Docker image for Fedora..."
    docker build -t localhost:5000/fedora-app:latest -f ./kubernetes/fedora/Dockerfile .

    Write-Host "Pushing Docker image for Fedora to registry..."
    docker push localhost:5000/fedora-app:latest

    Write-Host "Applying Kubernetes job for Fedora..."
    kubectl apply -f ./kubernetes/fedora/job.yaml
}

if ($archlinux -or $all) {
    if ($null -ne (kubectl get jobs | Select-String -Pattern "archlinux-job")) {
        Write-Host "Deleting existing archlinux-job..."
        kubectl delete job archlinux-job
    }

    Write-Host "Building Docker image for Arch Linux..."
    docker build -t localhost:5000/archlinux-app:latest -f ./kubernetes/archlinux/Dockerfile .

    Write-Host "Pushing Docker image for Arch Linux to registry..."
    docker push localhost:5000/archlinux-app:latest

    Write-Host "Applying Kubernetes job for Arch Linux..."
    kubectl apply -f ./kubernetes/archlinux/job.yaml
}

if ($opensuse -or $all) {
    if ($null -ne (kubectl get jobs | Select-String -Pattern "opensuse-job")) {
        Write-Host "Deleting existing opensuse-job..."
        kubectl delete job opensuse-job
    }

    Write-Host "Building Docker image for openSUSE..."
    docker build -t localhost:5000/opensuse-app:latest -f ./kubernetes/opensuse/Dockerfile .

    Write-Host "Pushing Docker image for openSUSE to registry..."
    docker push localhost:5000/opensuse-app:latest

    Write-Host "Applying Kubernetes job for openSUSE..."
    kubectl apply -f ./kubernetes/opensuse/job.yaml
}
