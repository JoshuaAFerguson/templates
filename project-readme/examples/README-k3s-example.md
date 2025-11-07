# AI Infra on K3s

**Production-ready K3s cluster for AI/ML workloads on ARM64 hardware**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![K3s](https://img.shields.io/badge/K3s-v1.28-blue?logo=kubernetes)](https://k3s.io/)
[![Platform](https://img.shields.io/badge/Platform-ARM64-green)](https://www.arm.com/)

---

## 🎯 Overview

This repository contains a complete Kubernetes infrastructure for running AI/ML workloads on a 4-node K3s cluster using Orange Pi 5 boards (ARM64, 16GB RAM per node, RK3588 CPU).

**Total Deliverables**: 40+ pre-configured applications
- **AI/ML Stack**: LLM inference, model serving, experiment tracking, vector databases
- **Development Tools**: Self-hosted Git, notebooks, automation workflows
- **Observability**: Full monitoring, logging, and alerting stack
- **Security**: SSO/IdP with MFA, secrets management, network policies

**Hardware**: Orange Pi 5 × 4 nodes (ARM64, RK3588, 16GB RAM each)

---

## ✨ Features

### Core Infrastructure
- ✅ K3s lightweight Kubernetes (ARM64-optimized)
- ✅ MetalLB for LoadBalancer services
- ✅ Traefik ingress controller (built-in)
- ✅ Longhorn distributed storage (optional)
- ✅ NFS provisioner for hardware NAS integration

### AI/ML Capabilities
- ✅ LiteLLM router (OpenAI-compatible API)
- ✅ Open WebUI for LLM interaction
- ✅ MLflow for experiment tracking
- ✅ Qdrant vector database
- ✅ llama.cpp for local model inference
- ✅ JupyterHub for multi-user notebooks

### Observability
- ✅ Prometheus + Grafana with custom dashboards
- ✅ Loki + Promtail for log aggregation
- ✅ Netdata real-time monitoring
- ✅ Uptime Kuma for service status
- ✅ Tempo distributed tracing (optional)

### Security
- ✅ Authentik SSO/IdP with MFA support
- ✅ Traefik ForwardAuth for centralized authentication
- ✅ Fail2Ban intrusion prevention
- ✅ HashiCorp Vault for secrets management
- ✅ Network policies and pod security standards

### Development Tools
- ✅ Gitea self-hosted Git with Actions (CI/CD)
- ✅ Portainer for visual management
- ✅ Guacamole for web-based SSH/RDP
- ✅ Semaphore UI for Ansible automation

---

## 📋 Prerequisites

### Hardware Requirements
- **Minimum**: 4 nodes with 16GB RAM each (64GB total)
- **Recommended**: Orange Pi 5 or similar ARM64 SBC
- **Storage**: SD card/eMMC for OS, SSD for container storage
- **Network**: Gigabit Ethernet, static IPs recommended

### Software Requirements
- **OS**: Ubuntu 22.04 ARM64 or Debian 11+
- **K3s**: v1.28.5+k3s1 or newer
- **kubectl**: Installed and configured
- **Optional**: Cloudflare account for public access

---

## 🚀 Quick Start

### 1. Install K3s

On the server node:
```bash
curl -sfL https://get.k3s.io | sh -s - server \
  --disable=traefik \
  --write-kubeconfig-mode=644
```

On agent nodes:
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://server-ip:6443 \
  K3S_TOKEN=<server-token> sh -
```

### 2. Clone Repository

```bash
git clone https://github.com/JoshuaAFerguson/ai-infra-k3s.git
cd ai-infra-k3s
```

### 3. Configure Network

Edit MetalLB IP range in `networking/metallb.yaml`:
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
    - 192.168.1.240-192.168.1.250  # Change to your free IP range
```

### 4. Deploy Base Stack

```bash
# Apply base infrastructure
kubectl apply -k .

# Monitor deployment
kubectl get pods -A --watch
```

### 5. Access Services

After deployment, find LoadBalancer IPs:
```bash
kubectl get svc -A | grep LoadBalancer
```

Key services:
- **Dashy Homepage**: http://dashy.local
- **Portainer**: https://portainer.local:9443
- **Grafana**: http://grafana.local (admin / prom-operator)
- **Open WebUI**: http://openwebui.local

---

## 🗂️ Project Structure

```
ai-infra-k3s/
├── cluster/               # Cluster-wide resources
│   └── namespaces.yaml
├── networking/            # Networking (MetalLB, ingress)
│   └── metallb.yaml
├── storage/               # Storage provisioners
│   ├── longhorn.yaml
│   └── nfs-provisioner.yaml
├── data/                  # Data layer (databases, caches)
│   ├── postgres.yaml
│   ├── redis.yaml
│   └── minio.yaml
├── ai/                    # AI/ML workloads
│   ├── litellm.yaml
│   ├── openwebui.yaml
│   └── mlflow.yaml
├── observability/         # Monitoring and logging
│   ├── prometheus-stack.yaml
│   └── loki-stack.yaml
├── auth/                  # Authentication services
│   └── authentik.yaml
├── security/              # Security tools
│   ├── vault.yaml
│   └── fail2ban.yaml
├── dev/                   # Development tools
│   ├── gitea.yaml
│   └── jupyterhub.yaml
├── tools/                 # Management tools
│   └── portainer.yaml
├── scripts/               # Deployment scripts
│   ├── 01-generate-secrets.sh
│   ├── 02-deploy-base.sh
│   └── 03-deploy-full.sh
└── kustomization.yaml     # Main kustomization file
```

---

## 🔧 Configuration

### Memory Planning

With 64GB total RAM, use the tiered deployment approach:

**Demo-Ready Profile** (~34GB, included by default):
- Visual management tools
- AI/ML core (without heavy models)
- Full observability
- Security hardening

**Optional Heavy Services** (enable as needed):
- llama.cpp local models: +8GB
- JupyterHub multi-user: +4GB
- Harbor container registry: +4GB

Check current usage:
```bash
kubectl top nodes
kubectl top pods -A | sort -k 4 -hr | head -20
```

### Customization

Edit `kustomization.yaml` to enable/disable services:
```yaml
resources:
  # Uncomment to enable
  # - ai/llama-daemonset.yaml
  # - dev/jupyterhub-helmchart.yaml
```

### Secrets Management

```bash
# Copy environment template
cp .env.example .env

# Edit with your credentials
vim .env

# Generate secrets
./scripts/01-generate-secrets.sh
```

---

## 📊 Monitoring

### Grafana Dashboards

Included dashboards:
- **Cluster Overview**: Node resources, pod status
- **AI Infra Metrics**: LLM latency, model performance
- **Storage Monitoring**: Volume usage, I/O metrics
- **Network Traffic**: Ingress/egress, service mesh

Access: http://grafana.local (admin / prom-operator)

### Resource Monitoring

```bash
# Node resources
kubectl top nodes

# Pod resources (top 20 by memory)
kubectl top pods -A | sort -k 4 -hr | head -20

# Watch pod status
kubectl get pods -A --watch
```

### Alerting

Alerts configured for:
- High CPU/memory usage (>80%)
- Pod restart loops
- Disk space warnings
- Service downtime

Alerts sent to Gotify/Slack (configure in `.env`)

---

## 🔒 Security

### Authentication

**Authentik SSO** (recommended):
- OAuth2/OIDC provider
- MFA support (TOTP, WebAuthn)
- Centralized access control
- Social login integration

Setup guide: `kubectl get cm -n authentik authentik-setup-docs -o yaml`

### Network Security

**Cloudflare Zero Trust** (optional):
1. Create tunnel in Cloudflare dashboard
2. Copy tunnel token to `cloudflared/secret.yaml`
3. Configure hostnames in `cloudflared/configmap.yaml`
4. Enable: Uncomment `cloudflared/deployment.yaml` in `kustomization.yaml`

**Fail2Ban**:
- Monitors auth failures
- Automatic IP banning
- Protects SSH, web services, applications

### Secrets Management

**HashiCorp Vault**:
- Centralized secrets storage
- Dynamic database credentials
- PKI and encryption as a service
- Kubernetes service account integration

---

## 🛠️ Maintenance

### Backup

Automated backups via Argo Workflows:
```bash
# Deploy backup workflow
kubectl apply -f pipelines/backup-workflow.yaml

# Manual backup
argo -n argo submit --from workflowtemplate/backups-nightly
```

Backs up:
- etcd database
- PostgreSQL databases
- Qdrant vector DB
- MinIO objects

### Upgrades

K3s cluster upgrades:
```bash
# On server node
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.29.0+k3s1 sh -

# On agent nodes
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.29.0+k3s1 sh -
```

Application upgrades:
- Renovate bot configured (`renovate.json`)
- Auto-creates PRs for new versions
- Manual approval before merging

---

## 📚 Documentation

- **[DEPLOYMENT_STRATEGY.md](DEPLOYMENT_STRATEGY.md)** - Memory planning and deployment profiles
- **[DEMO_GUIDE.md](DEMO_GUIDE.md)** - Demo scenarios and presentation scripts
- **[FAQ.md](FAQ.md)** - Frequently asked questions
- **[MEMORY_REALITY_CHECK.md](MEMORY_REALITY_CHECK.md)** - Resource optimization tips

---

## 🐛 Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

### MetalLB not assigning IPs

```bash
# Check MetalLB controller
kubectl logs -n metallb-system -l app=metallb

# Verify IP pool
kubectl get ipaddresspool -n metallb-system

# Check speaker pods
kubectl get pods -n metallb-system
```

### Out of memory errors

```bash
# Check resource usage
kubectl top nodes
kubectl top pods -A | sort -k 4 -hr

# Disable heavy services in kustomization.yaml
# Restart pods to free memory
```

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file.

---

## 🙏 Acknowledgments

- [K3s](https://k3s.io/) - Lightweight Kubernetes
- [LiteLLM](https://github.com/BerriAI/litellm) - LLM proxy
- [Open WebUI](https://github.com/open-webui/open-webui) - Web UI for LLMs
- [Authentik](https://goauthentik.io/) - SSO/IdP
- [Grafana](https://grafana.com/) - Observability platform

---

## 📧 Contact

**Joshua Ferguson**
- GitHub: [@JoshuaAFerguson](https://github.com/JoshuaAFerguson)
- Email: contact@joshua-ferguson.com

---

**Built with ❤️ for the AI Infrastructure community**
