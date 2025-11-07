# Ansible Runbooks for AI Infrastructure

Comprehensive Ansible automation for deploying and managing AI infrastructure, K3s clusters, and system hardening.

[![Ansible](https://img.shields.io/badge/Ansible-2.14+-red?logo=ansible)](https://www.ansible.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9+-blue?logo=python)](https://www.python.org/)

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Playbooks](#playbooks)
- [Roles](#roles)
- [Inventory Management](#inventory-management)
- [Variables](#variables)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Overview

This repository contains production-ready Ansible playbooks for:

- 🚀 **K3s Deployment**: Automated K3s cluster installation and configuration
- 🔒 **OS Hardening**: CIS benchmarks and security configurations
- 🐳 **Container Runtime**: Docker and containerd setup
- 📊 **Monitoring**: Prometheus, Grafana, and alerting stack
- 🔧 **System Configuration**: Common system setup and tools
- 🌐 **Networking**: Firewall rules, network policies
- 📦 **Package Management**: Automated package installation and updates

### Design Principles

- **Idempotent**: Safe to run multiple times
- **Modular**: Reusable roles and tasks
- **Tested**: Validated on multiple Linux distributions
- **Documented**: Comprehensive inline documentation
- **Secure**: Security-first approach

## Prerequisites

### Control Node (Your Machine)

```bash
# Required software
ansible --version  # 2.14+
python3 --version  # 3.9+

# Install Ansible
pip3 install ansible

# Install collections
ansible-galaxy collection install -r requirements.yml

# Install roles
ansible-galaxy role install -r requirements.yml
```

### Managed Nodes (Target Servers)

- **Operating System**: Ubuntu 20.04+, Debian 11+, Rocky Linux 8+
- **Python**: 3.8+ installed
- **SSH Access**: Root or sudo user with SSH key authentication
- **Network**: Outbound internet access for package downloads

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/JoshuaAFerguson/ansible-runbooks.git
cd ansible-runbooks
```

### 2. Configure Inventory

```bash
# Copy example inventory
cp inventory/hosts.example inventory/hosts

# Edit inventory
vim inventory/hosts
```

Example inventory:

```ini
[k3s_server]
k3s-master-01 ansible_host=192.168.1.10

[k3s_agents]
k3s-worker-01 ansible_host=192.168.1.11
k3s-worker-02 ansible_host=192.168.1.12
k3s-worker-03 ansible_host=192.168.1.13

[k3s:children]
k3s_server
k3s_agents

[gpu_nodes]
k3s-gpu-01 ansible_host=192.168.1.20

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
```

### 3. Configure Variables

```bash
# Copy example variables
cp group_vars/all.example.yml group_vars/all.yml

# Edit variables
vim group_vars/all.yml
```

### 4. Test Connectivity

```bash
# Ping all hosts
ansible all -i inventory/hosts -m ping

# Check facts
ansible all -i inventory/hosts -m setup
```

### 5. Run Playbooks

```bash
# System preparation
ansible-playbook -i inventory/hosts playbooks/00-system-prep.yml

# OS hardening
ansible-playbook -i inventory/hosts playbooks/01-os-hardening.yml

# Deploy K3s
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml
```

## Playbooks

### System Playbooks

#### `playbooks/00-system-prep.yml`

Prepares systems for cluster deployment.

**What it does:**
- Updates all packages
- Installs common utilities
- Configures NTP
- Sets up SSH keys
- Configures hostname and hosts file

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/00-system-prep.yml
```

**Tags:**
- `packages`: Package installation only
- `ssh`: SSH configuration only
- `hostname`: Hostname configuration only

#### `playbooks/01-os-hardening.yml`

Applies security hardening based on CIS benchmarks.

**What it does:**
- Configures sysctl parameters
- Sets up firewall (UFW/firewalld)
- Enables audit logging (auditd)
- Configures fail2ban
- Disables unnecessary services
- Sets file permissions
- Configures PAM security

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/01-os-hardening.yml
```

**Tags:**
- `firewall`: Firewall configuration
- `audit`: Audit logging
- `sysctl`: Kernel parameters
- `services`: Service configuration

### K3s Playbooks

#### `playbooks/02-k3s-deployment.yml`

Deploys K3s cluster (server and agents).

**What it does:**
- Installs K3s on server nodes
- Configures K3s with custom settings
- Deploys K3s agents
- Sets up kubectl access
- Configures kubeconfig for remote access

**Usage:**
```bash
# Deploy full cluster
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml

# Deploy server only
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml --tags k3s-server

# Deploy agents only
ansible-playbook -i inventory/hosts playbooks/02-k3s-deployment.yml --tags k3s-agent
```

**Variables:**
```yaml
k3s_version: v1.28.5+k3s1
k3s_server_options:
  - "--disable=traefik"
  - "--disable=servicelb"
k3s_agent_options:
  - "--node-label=node-role=worker"
```

#### `playbooks/03-k3s-upgrade.yml`

Upgrades K3s cluster to a new version.

**What it does:**
- Drains nodes before upgrade
- Upgrades K3s binaries
- Verifies node health after upgrade
- Uncordons nodes

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/03-k3s-upgrade.yml \
  -e k3s_version=v1.29.0+k3s1
```

### Monitoring Playbooks

#### `playbooks/04-monitoring-stack.yml`

Deploys monitoring infrastructure.

**What it does:**
- Installs Prometheus
- Installs Grafana
- Configures node-exporter
- Sets up default dashboards
- Configures alerting rules

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/04-monitoring-stack.yml
```

### GPU Playbooks

#### `playbooks/05-gpu-setup.yml`

Configures NVIDIA GPU support.

**What it does:**
- Installs NVIDIA drivers
- Installs CUDA toolkit
- Configures container runtime for GPU
- Deploys NVIDIA device plugin
- Validates GPU access

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/05-gpu-setup.yml \
  --limit gpu_nodes
```

### Maintenance Playbooks

#### `playbooks/backup.yml`

Backs up cluster configuration and data.

**What it does:**
- Backs up etcd database
- Backs up K3s configuration
- Backs up persistent volumes
- Uploads to backup storage

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/backup.yml
```

#### `playbooks/restore.yml`

Restores cluster from backup.

**Usage:**
```bash
ansible-playbook -i inventory/hosts playbooks/restore.yml \
  -e backup_date=2025-01-06
```

## Roles

### Role: `common`

Common system configuration.

**Tasks:**
- Package management
- User management
- SSH configuration
- Time synchronization

**Variables:**
```yaml
common_packages:
  - vim
  - htop
  - curl
  - wget
common_users:
  - name: deploy
    groups: sudo
```

### Role: `security_hardening`

Security configuration and hardening.

**Tasks:**
- Firewall configuration
- Auditd setup
- Fail2ban configuration
- SSH hardening
- Kernel hardening

**Variables:**
```yaml
security_ssh_port: 22
security_allowed_ports:
  - 22/tcp
  - 6443/tcp
  - 80/tcp
  - 443/tcp
```

### Role: `k3s_server`

K3s server installation and configuration.

**Tasks:**
- Download K3s binary
- Configure K3s server
- Start K3s service
- Generate kubeconfig

**Variables:**
```yaml
k3s_version: v1.28.5+k3s1
k3s_config_file: /etc/rancher/k3s/config.yaml
k3s_data_dir: /var/lib/rancher/k3s
```

### Role: `k3s_agent`

K3s agent installation and configuration.

**Tasks:**
- Download K3s binary
- Configure K3s agent
- Join cluster
- Verify connection

**Variables:**
```yaml
k3s_server_url: https://server-ip:6443
k3s_token: "{{ k3s_server_token }}"
```

### Role: `monitoring`

Monitoring stack deployment.

**Tasks:**
- Install Prometheus
- Install Grafana
- Configure data sources
- Deploy dashboards

**Variables:**
```yaml
prometheus_version: 2.45.0
grafana_version: 10.0.0
prometheus_retention: 15d
```

### Role: `gpu_support`

NVIDIA GPU configuration.

**Tasks:**
- Install NVIDIA drivers
- Configure container runtime
- Deploy device plugin
- Validate GPU access

**Variables:**
```yaml
nvidia_driver_version: "535.129.03"
cuda_version: "12.2"
```

## Inventory Management

### Directory Structure

```
inventory/
├── production/
│   ├── hosts              # Production servers
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── k3s.yml
│   │   └── gpu_nodes.yml
│   └── host_vars/
│       └── k3s-master-01.yml
├── staging/
│   ├── hosts
│   └── group_vars/
└── development/
    ├── hosts
    └── group_vars/
```

### Dynamic Inventory

For cloud environments, use dynamic inventory:

```bash
# AWS
ansible-playbook -i aws_ec2.yml playbook.yml

# Azure
ansible-playbook -i azure_rm.yml playbook.yml
```

## Variables

### Precedence Order

1. Extra vars (`-e` on command line)
2. Task vars
3. Role vars
4. Host vars
5. Group vars
6. Role defaults

### Important Variables

#### Global Variables (`group_vars/all.yml`)

```yaml
# Environment
environment: production

# Timezone
timezone: America/Phoenix

# Package mirror (optional)
apt_mirror: http://mirror.example.com/ubuntu

# Backup configuration
backup_enabled: true
backup_destination: s3
backup_s3_bucket: cluster-backups
```

#### K3s Variables (`group_vars/k3s.yml`)

```yaml
k3s_version: v1.28.5+k3s1
k3s_install_dir: /usr/local/bin
k3s_config_dir: /etc/rancher/k3s
k3s_data_dir: /var/lib/rancher/k3s

# Server configuration
k3s_server_options:
  - "--disable=traefik"
  - "--disable=servicelb"
  - "--write-kubeconfig-mode=644"

# Agent configuration
k3s_agent_options:
  - "--node-label=node-role=worker"

# TLS SANs
k3s_tls_san:
  - "k3s.example.com"
  - "192.168.1.10"
```

#### Monitoring Variables (`group_vars/monitoring.yml`)

```yaml
prometheus_retention: 15d
prometheus_storage_size: 50Gi
grafana_admin_password: "{{ vault_grafana_password }}"
alertmanager_slack_webhook: "{{ vault_slack_webhook }}"
```

### Vault Encryption

Sensitive variables should be encrypted with Ansible Vault:

```bash
# Create encrypted file
ansible-vault create group_vars/vault.yml

# Edit encrypted file
ansible-vault edit group_vars/vault.yml

# Run playbook with vault
ansible-playbook playbook.yml --ask-vault-pass

# Or use password file
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

Example `vault.yml`:

```yaml
vault_grafana_password: SecurePassword123!
vault_slack_webhook: https://hooks.slack.com/services/XXX/YYY/ZZZ
vault_backup_s3_access_key: AKIAIOSFODNN7EXAMPLE
vault_backup_s3_secret_key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

## Security

### SSH Key Authentication

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "ansible@k3s-cluster"

# Copy to managed nodes
ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@192.168.1.10
```

### Sudo Configuration

Ensure the Ansible user has passwordless sudo:

```bash
# On managed nodes
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ubuntu
```

### Firewall Rules

Default allowed ports:

- `22/tcp`: SSH
- `6443/tcp`: K3s API server
- `10250/tcp`: Kubelet metrics
- `2379-2380/tcp`: etcd (HA only)

Custom ports defined in `security_allowed_ports` variable.

## Troubleshooting

### Common Issues

#### Issue: Connection Timeout

**Problem**: Cannot connect to managed nodes

**Solution**:
```bash
# Test SSH connectivity
ssh -vvv ubuntu@192.168.1.10

# Check SSH config
ansible all -i inventory/hosts -m ping -vvv
```

#### Issue: Permission Denied

**Problem**: Sudo commands fail

**Solution**:
```bash
# Verify sudo access
ansible all -i inventory/hosts -m shell -a "sudo whoami" --become

# Check sudoers configuration
ansible all -i inventory/hosts -m shell -a "sudo cat /etc/sudoers.d/ubuntu"
```

#### Issue: K3s Installation Fails

**Problem**: K3s server won't start

**Solution**:
```bash
# Check K3s logs on server
ansible k3s_server -i inventory/hosts -m shell \
  -a "sudo journalctl -u k3s -n 100"

# Verify network connectivity
ansible k3s_server -i inventory/hosts -m shell \
  -a "sudo netstat -tulpn | grep 6443"
```

#### Issue: Module Not Found

**Problem**: Ansible module errors

**Solution**:
```bash
# Install missing collections
ansible-galaxy collection install -r requirements.yml --force

# Verify installation
ansible-galaxy collection list
```

### Debug Mode

Run playbooks with increased verbosity:

```bash
# Level 1: Standard debug output
ansible-playbook playbook.yml -v

# Level 2: More verbose
ansible-playbook playbook.yml -vv

# Level 3: Debug connection issues
ansible-playbook playbook.yml -vvv

# Level 4: Full debug (very verbose)
ansible-playbook playbook.yml -vvvv
```

### Syntax Check

Validate playbook syntax before running:

```bash
# Check syntax
ansible-playbook playbook.yml --syntax-check

# Dry run (check mode)
ansible-playbook playbook.yml --check

# Show diff of what would change
ansible-playbook playbook.yml --check --diff
```

## Best Practices

1. **Use Version Control**: Track all changes in git
2. **Test in Staging**: Always test playbooks in staging first
3. **Tag Your Playbooks**: Use tags for selective execution
4. **Encrypt Secrets**: Use Ansible Vault for sensitive data
5. **Document Changes**: Update documentation with code
6. **Use Roles**: Keep playbooks modular and reusable
7. **Idempotent Tasks**: Ensure tasks can run multiple times safely
8. **Error Handling**: Use `block/rescue` for error handling
9. **Verify Changes**: Include verification tasks
10. **Backup First**: Always backup before making changes

## Testing

### Molecule

Use Molecule for role testing:

```bash
# Install Molecule
pip3 install molecule molecule-docker

# Initialize Molecule
cd roles/common
molecule init scenario

# Run tests
molecule test
```

### Ansible Lint

Check playbook quality:

```bash
# Install ansible-lint
pip3 install ansible-lint

# Lint playbooks
ansible-lint playbooks/*.yml

# Lint roles
ansible-lint roles/*/tasks/main.yml
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Ansible CI

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run ansible-lint
        uses: ansible/ansible-lint-action@main

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          pip install ansible molecule molecule-docker
      - name: Run Molecule tests
        run: |
          cd roles/common
          molecule test
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## License

MIT License - See [LICENSE](LICENSE) file.

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [K3s Documentation](https://docs.k3s.io/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [Ansible Galaxy](https://galaxy.ansible.com/)

## Support

- **Issues**: [GitHub Issues](https://github.com/JoshuaAFerguson/ansible-runbooks/issues)
- **Email**: contact@joshua-ferguson.com

---

**Maintained by**: [Joshua Ferguson](https://github.com/JoshuaAFerguson)
