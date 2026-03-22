# Project 1: Multi-Region E-Commerce Platform with GitOps Deployment

## Architecture Overview
Multi-region microservices e-commerce app deployed across 2 AWS regions on EKS with GitOps (ArgoCD), Istio service mesh for canary releases, and Terraform IaC.

## Tools Demonstrated
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

## Quick Start
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

## Success Metrics
- Environment provisioning: <20 minutes via Terraform
- Deployment frequency: automated on every merge to main
- Zero-downtime releases via Istio canary (90/10 → 50/50 → 100)
- Cross-region failover: <60 seconds via Route 53 health checks
