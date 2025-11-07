# Ansible Playbook Guide

Quick reference guide for all available playbooks with usage examples, variables, and common scenarios.

## Table of Contents

- [System Preparation](#system-preparation)
- [Security Hardening](#security-hardening)
- [K3s Deployment](#k3s-deployment)
- [Monitoring](#monitoring)
- [GPU Configuration](#gpu-configuration)
- [Maintenance](#maintenance)
- [Common Patterns](#common-patterns)

## System Preparation

### 00-system-prep.yml

Prepares fresh systems for cluster deployment.

**Run order**: First playbook to run

**Estimated time**: 10-15 minutes

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/00-system-prep.yml
```

**With tags:**
```bash
# Update packages only
ansible-playbook -i inventory/hosts playbooks/00-system-prep.yml --tags packages

# Configure SSH only
ansible-playbook -i inventory/hosts playbooks/00-system-prep.yml --tags ssh

# Skip package updates
ansible-playbook -i inventory/hosts playbooks/00-system-prep.yml --skip-tags packages
```

**Key variables:**
```yaml
# group_vars/all.yml
common_packages:
  - vim
  - htop
  - curl
  - wget
  - net-tools

timezone: America/Phoenix

ntp_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
```

**What it configures:**
- ✅ System packages updated
- ✅ Common utilities installed
- ✅ NTP/Chrony configured
- ✅ Hostname set
- ✅ /etc/hosts configured
- ✅ SSH keys distributed
- ✅ Locale configured (UTF-8)

**Verify:**
```bash
ansible all -i inventory/hosts -m shell -a "timedatectl"
ansible all -i inventory/hosts -m shell -a "hostname"
```

## Security Hardening

### 01-os-hardening.yml

Applies CIS benchmark security hardening.

**Run order**: After system-prep, before K3s deployment

**Estimated time**: 15-20 minutes

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/01-os-hardening.yml
```

**With tags:**
```bash
# Firewall only
ansible-playbook -i inventory/hosts playbooks/01-os-hardening.yml --tags firewall

# Audit configuration only
ansible-playbook -i inventory/hosts playbooks/01-os-hardening.yml --tags audit

# Skip firewall (if using custom solution)
ansible-playbook -i inventory/hosts playbooks/01-os-hardening.yml --skip-tags firewall
```

**Key variables:**
```yaml
# group_vars/all.yml
security_ssh_port: 22
security_ssh_permit_root: false
security_ssh_password_auth: false

security_firewall_enabled: true
security_allowed_ports:
  - 22/tcp    # SSH
  - 6443/tcp  # K3s API
  - 80/tcp    # HTTP
  - 443/tcp   # HTTPS

security_fail2ban_enabled: true
security_fail2ban_bantime: 3600

security_auditd_enabled: true
security_audit_log_size: 500MB
```

**What it configures:**
- ✅ Firewall (UFW/firewalld) configured
- ✅ Fail2ban enabled and configured
- ✅ Auditd logging enabled
- ✅ SSH hardened (no root, no password)
- ✅ Kernel parameters tuned (sysctl)
- ✅ Unnecessary services disabled
- ✅ File permissions secured
- ✅ PAM security configured

**Verify:**
```bash
# Check firewall
ansible all -i inventory/hosts -m shell -a "sudo ufw status"

# Check fail2ban
ansible all -i inventory/hosts -m shell -a "sudo fail2ban-client status sshd"

# Check audit
ansible all -i inventory/hosts -m shell -a "sudo auditctl -l"
```

## K3s Deployment

### 02-k3s-deployment.yml

Deploys K3s cluster (server and agents).

**Run order**: After security hardening

**Estimated time**: 10-15 minutes

**Usage:**
```bash
# Deploy full cluster
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml

# Server only
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml --tags k3s-server

# Agents only
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml --tags k3s-agent

# Specific version
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml \
  -e k3s_version=v1.29.0+k3s1
```

**Key variables:**
```yaml
# group_vars/k3s.yml
k3s_version: v1.28.5+k3s1

k3s_server_options:
  - "--disable=traefik"
  - "--disable=servicelb"
  - "--write-kubeconfig-mode=644"
  - "--cluster-cidr=10.42.0.0/16"
  - "--service-cidr=10.43.0.0/16"

k3s_agent_options:
  - "--node-label=node-role=worker"

k3s_tls_san:
  - "k3s.example.com"
  - "192.168.1.10"
```

**What it configures:**
- ✅ K3s binary downloaded
- ✅ K3s server installed and started
- ✅ K3s agents joined to cluster
- ✅ Kubeconfig generated
- ✅ kubectl configured
- ✅ Node labels applied

**Verify:**
```bash
# On control node
export KUBECONFIG=~/.kube/k3s-config
kubectl get nodes
kubectl get pods -A

# Check K3s service
ansible k3s_server -i inventory/hosts -m shell -a "sudo systemctl status k3s"
ansible k3s_agents -i inventory/hosts -m shell -a "sudo systemctl status k3s-agent"
```

### 03-k3s-upgrade.yml

Upgrades K3s cluster to new version.

**Run order**: When upgrading existing cluster

**Estimated time**: 20-30 minutes (depends on cluster size)

**Usage:**
```bash
# Upgrade to specific version
ansible-playbook -i inventory/hosts playbooks/03-k3s-upgrade.yml \
  -e k3s_version=v1.29.0+k3s1

# Dry run (check what would happen)
ansible-playbook -i inventory/hosts playbooks/03-k3s-upgrade.yml \
  -e k3s_version=v1.29.0+k3s1 --check
```

**Key variables:**
```yaml
k3s_version: v1.29.0+k3s1  # Target version
k3s_upgrade_drain_timeout: 300  # Seconds
k3s_upgrade_verify: true  # Verify each node after upgrade
```

**What it does:**
1. Backs up K3s configuration
2. Drains server nodes one by one
3. Upgrades K3s binary
4. Restarts K3s service
5. Waits for node to be ready
6. Uncordons node
7. Repeats for all nodes

**Verify:**
```bash
kubectl get nodes -o wide
kubectl version
```

## Monitoring

### 04-monitoring-stack.yml

Deploys Prometheus/Grafana monitoring.

**Run order**: After K3s deployment

**Estimated time**: 10-15 minutes

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/04-monitoring-stack.yml
```

**Key variables:**
```yaml
# group_vars/monitoring.yml
prometheus_version: 2.45.0
prometheus_retention: 15d
prometheus_storage_size: 50Gi
prometheus_scrape_interval: 30s

grafana_version: 10.0.0
grafana_admin_user: admin
grafana_admin_password: "{{ vault_grafana_password }}"
grafana_storage_size: 10Gi

alertmanager_enabled: true
alertmanager_slack_webhook: "{{ vault_slack_webhook }}"
```

**What it deploys:**
- ✅ Prometheus server
- ✅ Grafana dashboard
- ✅ Node exporter (on all nodes)
- ✅ Alertmanager
- ✅ Default dashboards
- ✅ Alert rules

**Verify:**
```bash
kubectl get pods -n monitoring

# Port forward to access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Access: http://localhost:3000
# Username: admin
# Password: (from vault)
```

## GPU Configuration

### 05-gpu-setup.yml

Configures NVIDIA GPUs for ML workloads.

**Run order**: After K3s deployment, on GPU nodes only

**Estimated time**: 30-45 minutes (driver installation)

**Usage:**
```bash
# Configure all GPU nodes
ansible-playbook -i inventory/hosts playbooks/05-gpu-setup.yml --limit gpu_nodes

# Skip driver installation (if already installed)
ansible-playbook -i inventory/hosts playbooks/05-gpu-setup.yml \
  --limit gpu_nodes --skip-tags nvidia-driver

# Specific CUDA version
ansible-playbook -i inventory/hosts playbooks/05-gpu-setup.yml \
  --limit gpu_nodes -e cuda_version=12.2
```

**Key variables:**
```yaml
# group_vars/gpu_nodes.yml
nvidia_driver_version: "535.129.03"
cuda_version: "12.2"
nvidia_container_toolkit: true

# GPU time slicing (share GPUs)
gpu_time_slicing_enabled: false
gpu_time_slicing_replicas: 4
```

**What it configures:**
- ✅ NVIDIA drivers installed
- ✅ CUDA toolkit installed
- ✅ Container runtime configured for GPU
- ✅ NVIDIA device plugin deployed
- ✅ Runtime class created
- ✅ GPU validated

**Verify:**
```bash
# Check NVIDIA driver
ansible gpu_nodes -i inventory/hosts -m shell -a "nvidia-smi"

# Check device plugin
kubectl get pods -n kube-system | grep nvidia

# Test GPU access
kubectl run gpu-test --image=nvidia/cuda:12.2.0-base-ubuntu22.04 \
  --rm -it --restart=Never -- nvidia-smi
```

## Maintenance

### backup.yml

Backs up cluster configuration and data.

**Run order**: Regular maintenance (scheduled)

**Estimated time**: 5-10 minutes

**Usage:**
```bash
# Full backup
ansible-playbook -i inventory/hosts playbooks/backup.yml

# Backup to specific location
ansible-playbook -i inventory/hosts playbooks/backup.yml \
  -e backup_destination=/backup/2025-01-06

# Backup etcd only
ansible-playbook -i inventory/hosts playbooks/backup.yml --tags etcd
```

**Key variables:**
```yaml
backup_enabled: true
backup_destination: s3
backup_s3_bucket: k3s-backups
backup_s3_region: us-east-1
backup_retention_days: 30
```

**What it backs up:**
- ✅ Etcd database
- ✅ K3s configuration files
- ✅ SSL certificates
- ✅ Kubeconfig files

**Verify:**
```bash
# Check backup files
ansible k3s_server -i inventory/hosts -m shell \
  -a "ls -lh /var/backup/k3s/"

# Verify S3 backup
aws s3 ls s3://k3s-backups/
```

### restore.yml

Restores cluster from backup.

**Run order**: Disaster recovery only

**Usage:**
```bash
# Restore from specific backup
ansible-playbook -i inventory/hosts playbooks/restore.yml \
  -e backup_date=2025-01-06

# Restore etcd only
ansible-playbook -i inventory/hosts playbooks/restore.yml \
  -e backup_date=2025-01-06 --tags etcd
```

## Common Patterns

### Sequential Execution

Run multiple playbooks in order:

```bash
# Full cluster deployment
ansible-playbook -i inventory/hosts playbooks/00-system-prep.yml && \
ansible-playbook -i inventory/hosts playbooks/01-os-hardening.yml && \
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml && \
ansible-playbook -i inventory/hosts playbooks/04-monitoring-stack.yml
```

### Limit to Specific Hosts

```bash
# Run on specific host
ansible-playbook -i inventory/hosts playbook.yml --limit k3s-worker-01

# Run on specific group
ansible-playbook -i inventory/hosts playbook.yml --limit gpu_nodes

# Run on multiple hosts
ansible-playbook -i inventory/hosts playbook.yml --limit "k3s-worker-01,k3s-worker-02"
```

### Dry Run (Check Mode)

```bash
# See what would change
ansible-playbook -i inventory/hosts playbook.yml --check

# Show diff of changes
ansible-playbook -i inventory/hosts playbook.yml --check --diff
```

### Using Extra Variables

```bash
# Override variables
ansible-playbook -i inventory/hosts playbook.yml \
  -e k3s_version=v1.29.0+k3s1 \
  -e backup_enabled=true

# Load variables from file
ansible-playbook -i inventory/hosts playbook.yml \
  -e @custom_vars.yml
```

### Parallel Execution

```bash
# Control parallelism (default: 5)
ansible-playbook -i inventory/hosts playbook.yml --forks=10

# Serial execution (one host at a time)
ansible-playbook -i inventory/hosts playbook.yml --forks=1
```

### Using Vault

```bash
# With password prompt
ansible-playbook -i inventory/hosts playbook.yml --ask-vault-pass

# With password file
ansible-playbook -i inventory/hosts playbook.yml \
  --vault-password-file ~/.vault_pass

# Multiple vault IDs
ansible-playbook -i inventory/hosts playbook.yml \
  --vault-id prod@prompt --vault-id dev@~/.vault_dev
```

## Troubleshooting

### Failed Tasks

```bash
# Retry failed hosts
ansible-playbook -i inventory/hosts playbook.yml --limit @/tmp/playbook.retry

# Start at specific task
ansible-playbook -i inventory/hosts playbook.yml --start-at-task="Install K3s"

# Step through tasks
ansible-playbook -i inventory/hosts playbook.yml --step
```

### Debug Mode

```bash
# Verbose output
ansible-playbook -i inventory/hosts playbook.yml -v

# Very verbose
ansible-playbook -i inventory/hosts playbook.yml -vvv

# Debug connections
ansible-playbook -i inventory/hosts playbook.yml -vvvv
```

## Best Practices

1. **Always test in staging first**
2. **Use `--check` mode before running**
3. **Tag your tasks appropriately**
4. **Use Ansible Vault for secrets**
5. **Document your variables**
6. **Keep playbooks idempotent**
7. **Use roles for reusability**
8. **Version control everything**
9. **Backup before major changes**
10. **Monitor execution time**
