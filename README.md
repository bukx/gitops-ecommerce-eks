# 🛒 Multi-Region E-Commerce Platform with GitOps

![Validate](https://github.com/bukx/project-1-gitops-ecommerce/actions/workflows/validate.yml/badge.svg)

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat&logo=amazonaws&logoColor=white)
![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)
![Istio](https://img.shields.io/badge/Istio-466BB0?style=flat&logo=istio&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)

Production-grade multi-region microservices e-commerce platform deployed across **2 AWS regions** on EKS with **GitOps (ArgoCD)**, **Istio service mesh** for canary releases, and **Terraform IaC**.

---

## 🏗 Architecture

![Architecture Diagram](docs/architecture.png)

## 🔧 Tech Stack

| Tool | Usage |
|------|-------|
| **Terraform** | Provision VPCs, EKS, RDS, ElastiCache, ECR across 2 regions |
| **Docker** | Containerize 3 microservices (catalog, cart, checkout) |
| **Kubernetes (EKS)** | Orchestrate workloads across 2 regions |
| **Helm** | Package ArgoCD and Istio deployments |
| **ArgoCD** | GitOps-driven continuous deployment |
| **Istio** | Service mesh, canary traffic splitting |
| **GitHub Actions** | CI pipeline: test → build → push to ECR |
| **PostgreSQL (RDS)** | Primary + cross-region read replica |
| **Redis (ElastiCache)** | Session caching and cart state |
| **Route 53** | DNS-based failover between regions |

## 🚀 Quick Start

```bash
# 1. Provision infrastructure
cd terraform/environments/us-east-1 && terraform init && terraform apply

# 2. Install ArgoCD + Istio
helm install argocd helm/argocd/ -n argocd --create-namespace
helm install istio helm/istio/ -n istio-system --create-namespace

# 3. Register apps with ArgoCD
kubectl apply -f k8s/base/catalog/argocd-app.yaml

# 4. Push code → GitHub Actions builds → ArgoCD syncs automatically
git push origin main
```

## 📈 Key Outcomes

| Metric | Result |
|--------|--------|
| Environment provisioning | < 20 minutes via Terraform |
| Deployment frequency | Automated on every merge to main |
| Zero-downtime releases | Istio canary: 90/10 → 50/50 → 100 |
| Cross-region failover | < 60 seconds via Route 53 health checks |

## 📁 Project Structure

```
├── .github/workflows/    # CI pipeline (GitHub Actions)
├── helm/                 # ArgoCD + Istio Helm charts
├── k8s/base/             # Kubernetes manifests (Kustomize)
├── services/             # Microservice source code + Dockerfiles
└── terraform/            # IaC modules (VPC, EKS, RDS)
```

## 📜 License

This project is for portfolio/demonstration purposes.
