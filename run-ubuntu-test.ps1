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

# Delete Job if it exists
if ($null -ne (kubectl get jobs | Select-String -Pattern "ubuntu-job")) {
    Write-Host "Deleting existing ubuntu-job..."
    kubectl delete job ubuntu-job
}

# Build Docker image
Write-Host "Building Docker image..."
docker build -t localhost:5000/ubuntu-app:latest -f ./kubernetes/ubuntu/Dockerfile .

# Push Docker image to the registry
Write-Host "Pushing Docker image to registry..."
docker push localhost:5000/ubuntu-app:latest

# Apply Kubernetes Job
Write-Host "Applying Kubernetes job..."
kubectl apply -f ./kubernetes/ubuntu/job.yaml
