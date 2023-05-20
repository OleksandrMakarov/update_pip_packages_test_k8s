param (
    [switch]$ubuntu,
    [switch]$centos7,
    [switch]$all,
    [switch]$help
)

function Show-Help {
    @"
Usage: .\run-test.ps1 [options]

Options:
    -ubuntu     Run the test for Ubuntu.
    -centos7    Run the test for CentOS 7.
    -all        Run the test for all containers.
    -help       Show this help message.
"@
}

if ($help) {
    Show-Help
    exit
}

if (!$ubuntu -and !$centos7 -and !$all) {
    Write-Host "No options specified. Run .\run-test.ps1 -help for usage instructions."
    exit
}

# Check if minikube is already running
if ($null -eq (minikube status | Select-String -Pattern "host: Running")) {
    Write-Host "Starting minikube..."
    minikube start
    Write-Host "Waiting for minikube and local registry to start up..."
    Start-Sleep -Seconds 60
} else {
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
    # Delete Job if it exists
    if ($null -ne (kubectl get jobs | Select-String -Pattern "centos7-job")) {
        Write-Host "Deleting existing centos7-job..."
        kubectl delete job centos7-job
    }

    # Build Docker image
    Write-Host "Building Docker image for CentOS 7..."
    docker build -t localhost:5000/centos7-app:latest -f ./kubernetes/centos7/Dockerfile .

    # Push Docker image to the registry
    Write-Host "Pushing Docker image for CentOS 7 to registry..."
    docker push localhost:5000/centos7-app:latest

    # Apply Kubernetes Job
    Write-Host "Applying Kubernetes job for CentOS 7..."
    kubectl apply -f ./kubernetes/centos7/job.yaml
}
