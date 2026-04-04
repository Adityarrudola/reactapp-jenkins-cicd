# 🚀 Jenkins CI/CD with Docker-in-Docker (DinD) + Azure Deployment

A fully containerized CI/CD pipeline using Jenkins, Docker-in-Docker (DinD), and Microsoft Azure.

This project focuses not just on pipelines, but on **CI infrastructure design**, exploring how Jenkins can be run inside containers with proper isolation and deployment capabilities.

---

## 🧠 Architecture Overview

This setup uses a **containerized Jenkins environment** with a separate Docker daemon (DinD) to build and manage images.
<img width="1162" height="245" alt="image" src="https://github.com/user-attachments/assets/62c5b517-8a92-42d3-ae6f-1ac7921ad805" />

---

## ⚙️ Tech Stack

- Jenkins (Dockerized)
- Docker-in-Docker (DinD)
- Azure CLI
- Azure Container Registry (ACR)
- Azure Container Instances (ACI)
- React (Sample App)

---

## 🏗️ Key Features

- Fully containerized Jenkins setup
- Isolated Docker builds using DinD
- Secure Azure authentication using Service Principal
- End-to-end CI/CD pipeline (Build → Push → Deploy)
- Idempotent deployments (auto delete old container)
- Docker cleanup to manage disk usage
- Manual approval before deployment

---

## 🔄 CI/CD Pipeline Stages

1. Approval Stage – Manual approval before deployment  
2. Clean Workspace – Removes old files to avoid conflicts  
3. Checkout Code – Pulls latest code from GitHub  
4. Build Image – Builds Docker image  
5. Push to ACR – Pushes image to Azure Container Registry  
6. Delete Old Container – Avoids naming conflicts  
7. Deploy to ACI – Deploys container to Azure  
8. Cleanup Docker – Frees up disk space  

---

## 🔐 Credentials Required

Configured in Jenkins:

- azure-sp (Azure Service Principal)
  - Subscription ID
  - Client ID
  - Client Secret
  - Tenant ID

---

## ⚖️ Design Decision: DinD vs Docker Socket Binding

### Docker Socket Binding
Mounts host Docker inside Jenkins container (`/var/run/docker.sock`)

Pros:
- Faster
- Simpler setup

Cons:
- No isolation
- Security risk (container gets host-level control)
- Shared Docker environment

---

### Docker-in-Docker (DinD) [Used in this Project]

Runs a separate Docker daemon inside another container.

Pros:
- Strong isolation between builds
- Clean and reproducible environments
- Better suited for controlled CI setups

Cons:
- Slight performance overhead
- More setup complexity

---

## 🧠 Key Learnings

- CI/CD is not just pipelines — it’s infrastructure design
- Container networking is critical in multi-container setups
- Proper credential management is essential for cloud integration
- Pipelines are highly sensitive to environment variables
- Cleanup and resource management are necessary for long-running systems

---

## 🧪 Debugging Highlights

- Fixed Docker daemon communication issue between Jenkins and DinD
- Resolved shell compatibility issue (`/bin/sh` vs Bash)
- Debugged missing environment variable causing deployment failure
- Handled Azure container naming conflicts with delete stage
- Managed disk usage using Docker cleanup

---

## ⚠️ Production Considerations

- DinD is great for learning and isolated environments
- In production, alternatives include:
  - Kubernetes-based Jenkins agents
  - Remote Docker hosts
  - Secure Docker socket usage

---

## 🔗 Repository

https://github.com/Adityarrudola/reactapp-jenkins-cicd
