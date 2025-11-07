# K3s Infrastructure Template

This template provides reusable Kubernetes/K3s configurations extracted from production deployments. Use this as a starting point for new K3s clusters or AI/ML infrastructure projects.

## What's Included

This template contains:

- **Cluster Setup**: K3s installation and configuration scripts
- **Networking**: CNI, ingress, and service mesh configs
- **Storage**: Persistent volume and storage class definitions
- **Monitoring**: Prometheus, Grafana, and alerting stack
- **GPU Support**: NVIDIA device plugin and runtime configurations
- **Security**: Network policies, RBAC, and pod security standards
- **CI/CD**: GitOps with ArgoCD or Flux
- **ML/AI Workloads**: Job templates, model serving, and scheduling

## Quick Start

```bash
# Clone this template
git clone https://github.com/JoshuaAFerguson/k3s-infrastructure-template.git
cd k3s-infrastructure-template

# Customize configuration
cp config.example.yaml config.yaml
vim config.yaml

# Deploy K3s cluster
./scripts/deploy-cluster.sh

# Verify deployment
kubectl get nodes
kubectl get pods -A
```

## Directory Structure

```
k3s-template/
├── README.md                     # This file
├── config.example.yaml           # Complete cluster configuration
├── .env.example                  # Environment variables template
├── scripts/                      # Deployment automation
│   ├── deploy-base.sh           # Deploy base infrastructure
│   └── generate-secrets.sh      # Generate Kubernetes secrets
└── examples/                     # Example manifests and configs
    ├── kustomization.yaml       # Example Kustomize configuration
    └── namespaces.yaml          # Standard namespace definitions
```

### Using This Template

When starting a new K3s project:

```bash
# 1. Copy template to your project
cp -r k3s-template/ ~/my-k3s-project/

# 2. Customize configuration
cd ~/my-k3s-project
cp config.example.yaml config.yaml
cp .env.example .env
vim config.yaml .env

# 3. Create your directory structure
mkdir -p {cluster,networking,storage,monitoring,data,apps}

# 4. Copy example manifests as starting points
cp examples/namespaces.yaml cluster/
cp examples/kustomization.yaml .

# 5. Make scripts executable
chmod +x scripts/*.sh

# 6. Deploy
./scripts/generate-secrets.sh
./scripts/deploy-base.sh
```

## Configuration

### config.yaml

```yaml
cluster:
  name: k3s-prod
  version: v1.28.5+k3s1

  server:
    count: 1
    tls_san:
      - "k3s.example.com"
      - "192.168.1.100"

  agents:
    count: 3
    labels:
      node-role: worker
      gpu: "true"  # For GPU nodes

networking:
  cni: cilium  # or flannel, calico
  serviceCIDR: 10.43.0.0/16
  clusterCIDR: 10.42.0.0/16
  ingress:
    enabled: true
    controller: traefik  # or nginx
    class: traefik

storage:
  default_storage_class: local-path
  longhorn:
    enabled: true
    replicas: 3

monitoring:
  prometheus:
    enabled: true
    retention: 15d
    storage: 50Gi
  grafana:
    enabled: true
    admin_password: changeme

gpu:
  enabled: true
  nvidia_runtime: true
  device_plugin: true

ml_workloads:
  model_serving:
    enabled: true
    replicas: 2
    gpu_required: true
```

## Extraction Guide

To extract configs from your existing K3s project (`ai-infra-k3s`):

### 1. Cluster Configuration

```bash
# Copy K3s configuration files
cp ~/projects/ai-infra-k3s/k3s-config.yaml cluster/
cp ~/projects/ai-infra-k3s/k3s-agent-config.yaml cluster/

# Remove environment-specific values
# Replace with template variables: {{ .cluster.name }}
```

### 2. Kubernetes Manifests

```bash
# Extract namespace configurations
kubectl get namespaces -o yaml > kubernetes/namespaces/all-namespaces.yaml

# Extract storage classes
kubectl get storageclass -o yaml > kubernetes/storage/storage-classes.yaml

# Extract persistent volumes (sanitized)
kubectl get pv -o yaml > kubernetes/storage/persistent-volumes.yaml
```

### 3. Monitoring Stack

```bash
# Export Prometheus configuration
kubectl get configmap -n monitoring prometheus-config -o yaml > \
  kubernetes/monitoring/prometheus-config.yaml

# Export Grafana dashboards
kubectl get configmap -n monitoring grafana-dashboards -o yaml > \
  kubernetes/monitoring/grafana-dashboards.yaml
```

### 4. GPU Configuration

```bash
# Extract NVIDIA device plugin
kubectl get daemonset -n kube-system nvidia-device-plugin-daemonset -o yaml > \
  kubernetes/gpu/nvidia-device-plugin.yaml

# Extract runtime class
kubectl get runtimeclass nvidia -o yaml > \
  kubernetes/gpu/nvidia-runtime-class.yaml
```

### 5. Scripts

```bash
# Copy deployment scripts
cp ~/projects/ai-infra-k3s/scripts/*.sh scripts/

# Generalize paths and variables
# Replace hardcoded values with config.yaml references
```

### 6. Documentation

Extract documentation from your project:

```bash
# Copy relevant docs
cp ~/projects/ai-infra-k3s/docs/*.md docs/

# Update paths and references
# Remove environment-specific information
```

## Sanitization Checklist

Before sharing this template publicly:

- [ ] Remove IP addresses (replace with placeholders)
- [ ] Remove hostnames (use example.com)
- [ ] Remove secrets and credentials
- [ ] Remove internal URLs
- [ ] Generalize node names
- [ ] Remove org-specific configurations
- [ ] Replace actual values with {{ template.variables }}
- [ ] Add clear comments explaining configurations
- [ ] Test deployment on fresh cluster

## Usage Examples

### Deploy Basic Cluster

```bash
# Configure cluster
vim config.yaml

# Deploy K3s server
./scripts/deploy-cluster.sh --role server

# Add agent nodes
./scripts/add-node.sh --role agent --server https://server-ip:6443
```

### Enable GPU Support

```bash
# Install NVIDIA drivers on nodes first
# Then deploy GPU operator
kubectl apply -f kubernetes/gpu/

# Verify
kubectl get pods -n gpu-operator
```

### Deploy Monitoring

```bash
# Deploy Prometheus stack
kubectl apply -f kubernetes/monitoring/prometheus/
kubectl apply -f kubernetes/monitoring/grafana/

# Access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

### Deploy ML Workload

```bash
# Use job template
kubectl apply -f kubernetes/ml-workloads/training-job-template.yaml

# Monitor job
kubectl logs -f job/ml-training-job
```

## Customization

### For Different Use Cases

**Development Cluster:**
```yaml
cluster:
  agents:
    count: 1
monitoring:
  prometheus:
    retention: 7d
storage:
  longhorn:
    replicas: 1
```

**Production Cluster:**
```yaml
cluster:
  server:
    count: 3  # HA
  agents:
    count: 5
monitoring:
  prometheus:
    retention: 30d
storage:
  longhorn:
    replicas: 3
```

**GPU-Intensive Workloads:**
```yaml
cluster:
  agents:
    count: 4
    labels:
      gpu: "true"
      gpu-memory: "24GB"
gpu:
  enabled: true
  time_slicing: false  # Dedicate full GPU
```

## Best Practices

1. **Version Everything**: Pin versions for reproducibility
2. **Use GitOps**: Manage cluster state with ArgoCD/Flux
3. **Backup Regularly**: Automated etcd backups
4. **Monitor Everything**: Comprehensive observability
5. **Security First**: Network policies, RBAC, PSP
6. **Document Changes**: Keep docs updated
7. **Test Upgrades**: Test in staging first

## Integration with Other Projects

This template works well with:

- **Ansible Runbooks**: Use for OS-level configuration
- **Terraform**: Provision infrastructure before K3s
- **CI/CD**: GitHub Actions for automated deployments
- **Monitoring**: Integrate with external monitoring systems

## Contributing

Improvements welcome! See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - See [LICENSE](LICENSE)

## Resources

- K3s Documentation: https://docs.k3s.io
- Kubernetes Documentation: https://kubernetes.io/docs
- NVIDIA GPU Operator: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator
- Prometheus Operator: https://prometheus-operator.dev
