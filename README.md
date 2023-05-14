# Handbook of Kubernetes

## This handbook describes how to create environment for testing python application on any Linux distributive on Windows host

This project is developed for runing and testing application on different Linux systems
[Update Pip and App Packages](https://github.com/OleksandrMakarov/update-pip-project)


## 1. Prerequisites

VirtualBox - <https://www.virtualbox.org/>  
Kubectl - <https://kubernetes.io/docs/tasks/tools/install-kubectl/>  
Minikube - <https://kubernetes.io/docs/tasks/tools/install-minikube/>

## 2. Install

```powershell
# create directory for kubectl and minikube
cd C:\K8s

# download kubectl
curl -LO "https://dl.k8s.io/release/v1.27.1/bin/windows/amd64/kubectl.exe"

# download minikube
Invoke-WebRequest -OutFile 'c:\K8s\minikube.exe' -Uri 'https://github.com/kubernetes/minikube/releases/latest/download/minikube-windows-amd64.exe' -UseBasicParsing

# add directory to the path env
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = $oldPath + ";C:\K8s"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

#check kubectl and minikube
kubectl version
minikube version
```

## 3. Start cluster

```powershell
# virtualbox driver
minikube start --cpus=4 --memory=6gb --disk-size=30gb --driver=virtualbox --no-vtx-check=true
```

or

```powershell
# hyper-v driver
minikube start --cpus=4 --memory=4gb --disk-size=30gb --driver=hyperv --hyperv-virtual-switch="minikube-ext-net"
```

If you need to use virtualbox driver and don't want to disable hyper-v run with flag **--no-vtx-check=true**

## 4. Create a local repository for images

```powershell
# start minikube
minikube start

# enable the registry addon.
minikube addons enable registry
```

Repository will be available on port :5000

Next command sets the Docker environment variables so that all subsequent Docker commands in that PowerShell session interact with the Docker daemon inside Minikube, and not with your local Docker daemon.

```powershell
minikube -p minikube docker-env | Invoke-Expression
```

## 5. Create `Dockerfile` for image

This file depends on Linux distributive for testing

`./kubernetes/ubuntu/Dockerfile`

```Dockerfile
# Download the latest version of Ubuntu
FROM ubuntu:latest

# Update system and install python3 and pip
RUN apt update && apt install -y python3 python3-pip

# Copy the app directory and start.sh into the Docker image
COPY ./app /app

# Get the latest .whl file and install the application
RUN pip3 install $(ls -Art /app/*.whl | tail -n 1)

# Give execution rights to the start.sh script
RUN chmod +x /app/start.sh

```

`./app/start.sh`

```bash
#!/bin/bash

{
    update-pip-packages -v
    update-pip-packages --version
    update-pip-packages -h
    update-pip-packages --help
    update-pip-packages --app
    update-pip-packages --pip
} &>"/hostPath/ubuntu_$(date +%Y%m%d%H%M%S).log"

```

## Create `deployment.yaml` using a `Job` resource

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: ubuntu-job
  labels:
    app: ubuntu-app
spec:
  template:
    metadata:
      labels:
        app: ubuntu-app
    spec:
      containers:
        - name: ubuntu-container
          image: localhost:5000/ubuntu-app:latest
          imagePullPolicy: Always
          command: ["/bin/bash", "-c", "/app/start.sh"]
          volumeMounts:
            - name: host-volume
              mountPath: /hostPath
      restartPolicy: Never
      volumes:
        - name: host-volume
          hostPath:
            path: /hostPath
  backoffLimit: 4
```

Explanation:

- `apiVersion` specifies the API version you want to use (`batch/v1` for Job).
- `kind` specifies the type of Kubernetes resource you want to create (in this case, `Job`).
- `metadata` contains metadata such as the name of the Job and its labels.
- `spec` contains the Job specification, including the Pod template, restart strategy, and retry limits.
  - `template` defines the Pod template that will be created by the Job.
  - `spec.containers` describes the containers that will be run in the Pod.
  - `restartPolicy` defines the restart strategy for containers in case of failure. For Jobs, this is usually set to `Never` or `OnFailure`.
  - `volumes` defines the volumes available to the Pods. In this case, a `hostPath` volume is used, which mounts a file or directory from the host node's filesystem into the Pod.
  - `spec.containers.volumeMounts` defines where the volume will be mounted inside the container.
  - `backoffLimit` specifies the maximum number of retries before marking this Job as failed. Default is 6.

This Job configuration will create a Pod that runs the specified container. The container will execute the command `/bin/bash -c "/app/start.sh"`. The output will be written to the `hostPath` volume mounted at `/hostPath` in the container. If the container fails, Kubernetes will not restart it (`restartPolicy: Never`). If a job cannot be completed after 4 attempts (backoffLimit: 4), it will be marked as failed.


## Create `deployment.yaml` using a `Deployment` resource. (It doesn't meet my goals in this project. Just as an example)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ubuntu-deployment
  labels:
    app: ubuntu-app
spec:
  strategy:
    type: Recreate
  replicas: 1
  selector:
    matchLabels:
      app: ubuntu-app
  template:
    metadata:
      labels:
        app: ubuntu-app
    spec:
      containers:
        - name: ubuntu-container
          image: localhost:5000/ubuntu-app:latest
          imagePullPolicy: Always
          command: ["/bin/bash", "-c", "/app/start.sh"]
          volumeMounts:
            - name: host-volume
              mountPath: /hostPath
      volumes:
        - name: host-volume
          hostPath:
            path: /hostPath
```

In this file:

- `apiVersion: apps/v1` specifies the version of the Kubernetes API.
- `kind: Deployment` indicates that you want to create a Deployment object.
- `metadata` contains metadata about the object, including its name and labels.
- `spec` describes the desired state of the object.
- `replicas: 1` specifies that you want to create one replica of your Pod.
- `selector` is used to find which Pods the Deployment should manage.
- `template` defines the Pod template that the Deployment will use to create new Pods.
- `spec.containers` describes the containers that should be run in each Pod created by the Deployment.
- `volumeMounts` and `volumes` are used to mount the volume into your container.

## Create `service.yaml` for network access to pod. (It doesn't meet my goals in this project.)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ubuntu-service
  labels:
    app: ubuntu-app
spec:
  type: NodePort
  ports:
    - port: 8080
      targetPort: 8080
      protocol: TCP
      name: http
  selector:
    app: ubuntu-app
```

In this file:

- `apiVersion: v1` is used to specify the version of the Kubernetes API we're using.
- `kind: Service` indicates that we want to create a Service object.
- `metadata` contains the metadata of our object, including its name and labels.
- `spec` describes the desired state of our object.
- `type: NodePort` indicates that we want to use NodePort to expose our Service to the outside.
- `ports` describes the ports that our Service will use. In this case, we're using port 8080.
- `selector` defines which Pods our Service will serve. In this case, it will serve any Pods with the label `app: ubuntu-app`.

## Run the Job

```powershell
# For using docker daemon inside minikube or if you don't have Docker on the host (for using Docker daemon on host this step can be skipped)
minikube docker-env | Invoke-Expression

# Go to project folder
cd "D:\Work\Git_repos\update_pip_packages_test_k8s"

# Build the Docker image
docker build -t 192.168.59.100:5000/ubuntu-app:latest -f ./kubernetes/ubuntu/Dockerfile .
# or
docker build -t localhost:5000/ubuntu-app:latest -f ./kubernetes/ubuntu/Dockerfile .

# Push the image to the local registry
docker push 192.168.59.100:5000/ubuntu-app:latest
# or
docker push localhost:5000/ubuntu-app:latest

# Apply config and run job
kubectl apply -f ./kubernetes/ubuntu/deployment.yaml
```

## Useful commands

```powershell
# Pod log
kubectl logs <pod_name>

# or if you have several containers in one pod
kubectl logs <pod_name> -c <container_name>

# To check `stdout` and `stderr` in real time
kubectl logs -f <pod_name>

# Find a podname (-n <namespace> is additional key)
kubectl get pods -n <namespace>

# Stop and start pods
kubectl scale job <job_name> --replicas=0
kubectl scale job <job_name> --replicas=<desired_number>

# Delete job
kubectl delete job <job_name>

# If pod was created without deploment or job
kubectl delete pod <pod_name>

# Shows all images
docker images

# Shows all images including intermediate image layers
docker images -a

# This command is used to find Docker images that are "dangling."
docker images -f dangling=true

# This command is used to delete all Docker images that are "dangling."
docker rmi $(docker images -f dangling=true -q)
#or
docker image prune -a
```