# GitOps E-Commerce Platform on EKS

Production-style microservices platform deployed on Amazon EKS with Terraform, Helm, Argo CD, Istio, and GitHub Actions. The repo models how a platform team could run GitOps-driven application delivery, service mesh traffic management, and cross-region e-commerce infrastructure from a single codebase.

![Architecture Diagram](docs/architecture.png)

## Why this repo matters

This is one of the strongest portfolio repos because it combines several important concerns in one place: infrastructure provisioning, CI, GitOps delivery, service mesh rollout control, and application-level failover patterns.

## What is included

- Terraform infrastructure for AWS networking, EKS, data stores, and supporting services
- microservice source code under `services/`
- Argo CD and Istio Helm charts
- Kubernetes manifests under `k8s/`
- GitHub Actions workflows under `.github/`
- architecture and supporting docs under `docs/`

## Platform design

- **Infrastructure:** Terraform provisions VPCs, EKS, RDS, ElastiCache, and ECR across two AWS regions
- **Packaging:** Docker images are built from the microservices in `services/`
- **Delivery:** GitHub Actions builds and publishes artifacts
- **GitOps:** Argo CD synchronizes Kubernetes state from Git
- **Traffic control:** Istio handles service mesh policy and canary release patterns
- **Resilience:** Route 53 supports DNS-based regional failover

## Quick start

```bash
# Provision infrastructure
cd terraform/environments/us-east-1 && terraform init && terraform apply

# Install Argo CD and Istio
helm install argocd helm/argocd/ -n argocd --create-namespace
helm install istio helm/istio/ -n istio-system --create-namespace

# Register an application with Argo CD
kubectl apply -f k8s/base/catalog/argocd-app.yaml

# Push code and let the pipeline deliver the change
git push origin main
```

## Repository layout

```text
.
|-- services/            # microservice code and Dockerfiles
|-- helm/                # Argo CD and Istio Helm charts
|-- k8s/                 # Kubernetes manifests
|-- terraform/           # AWS infrastructure
|-- docs/                # diagrams and supporting documentation
`-- .github/             # GitHub Actions workflows
```

## What this demonstrates

- GitOps-driven Kubernetes delivery on AWS
- service mesh-based canary rollout patterns
- end-to-end platform engineering across CI, IaC, and runtime operations
- practical architecture for a resilient multi-service application
