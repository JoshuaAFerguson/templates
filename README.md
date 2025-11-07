# Project Templates

Collection of professional templates for GitHub projects, documentation, and infrastructure.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub](https://img.shields.io/badge/GitHub-Templates-blue?logo=github)](https://github.com/JoshuaAFerguson/templates)

## What's Included

This repository contains production-ready templates for:

- 📝 **Project README**: Comprehensive README.md template for any project
- 📚 **Ansible Documentation**: Complete documentation for Ansible runbooks and playbooks
- ☸️ **K3s Infrastructure**: K3s cluster configuration templates and deployment guides
- 📖 **Setup Guides**: Step-by-step guides for GitHub profile, portfolio, and more

## Templates

### 1. Project README Template

**Location**: [`project-readme/README.template.md`](project-readme/README.template.md)

A comprehensive README template with everything you need:

- Complete structure with table of contents
- Badges and project metadata
- Installation and usage instructions
- Architecture and deployment sections
- Troubleshooting and best practices
- Contributing guidelines

**Quick Start:**
```bash
# Copy to your project
cp project-readme/README.template.md /path/to/your-project/README.md

# Customize for your project
cd /path/to/your-project
vim README.md
```

**What to customize:**
- Replace `PROJECT-NAME` with your actual project name
- Update badges with your repository info
- Add your features and prerequisites
- Document your installation process
- Include real usage examples
- Update contact information

### 2. Ansible Documentation Templates

**Location**: [`ansible-docs/`](ansible-docs/)

Professional documentation templates for Ansible projects:

#### RUNBOOKS_README.md
Complete runbook documentation including:
- Playbook descriptions and usage
- Role documentation
- Inventory management
- Variable configuration
- Security best practices
- Troubleshooting guide
- CI/CD integration

#### PLAYBOOK_GUIDE.md
Quick reference guide with:
- Usage examples for each playbook
- Common patterns and workflows
- Tag usage and parallel execution
- Debugging techniques
- Best practices

**Quick Start:**
```bash
# Copy to your Ansible project
cp ansible-docs/* /path/to/ansible-project/docs/

# Customize for your playbooks
cd /path/to/ansible-project/docs
vim RUNBOOKS_README.md
vim PLAYBOOK_GUIDE.md
```

### 3. K3s Infrastructure Template

**Location**: [`k3s-template/`](k3s-template/)

Reusable K3s cluster configuration template:

#### config.example.yaml
Complete cluster configuration including:
- Cluster setup and versioning
- Server and agent node configuration
- Networking (CNI, ingress, service mesh)
- Storage (Longhorn, NFS, local-path)
- Monitoring (Prometheus, Grafana, Loki)
- GPU support (NVIDIA drivers, device plugin)
- ML/AI workload configurations
- Security (network policies, RBAC, pod security)
- Backup configuration
- GitOps setup (ArgoCD/Flux)
- High availability options

#### README.md
Comprehensive guide with:
- Quick start instructions
- Directory structure
- Configuration examples
- Extraction guide from existing K3s deployments
- Usage examples
- Customization for different use cases
- Best practices

**Quick Start:**
```bash
# Copy to your K3s project
cp k3s-template/config.example.yaml /path/to/k3s-project/config.yaml

# Customize configuration
cd /path/to/k3s-project
vim config.yaml

# Deploy cluster (using your deployment scripts)
./scripts/deploy-cluster.sh
```

**What to customize:**
- Cluster name and version
- Node counts and labels
- Network CIDRs and CNI choice
- Storage backends
- Monitoring retention and storage sizes
- GPU configuration (if applicable)
- Security policies
- Backup destinations

### 4. Setup Guides

**Location**: [`guides/`](guides/)

Step-by-step guides for common GitHub setup tasks:

#### SETUP_GUIDE.md
Instructions for:
- Creating GitHub profile README
- Deploying portfolio to GitHub Pages
- Configuring custom domains
- Adding analytics and SEO
- Testing locally
- Regular maintenance

**Quick Start:**
```bash
# View the guide
cat guides/SETUP_GUIDE.md

# Follow instructions for your specific needs
```

## Related Repositories

These templates complement other repositories:

- **[JoshuaAFerguson/JoshuaAFerguson](https://github.com/JoshuaAFerguson/JoshuaAFerguson)** - GitHub profile README
- **[JoshuaAFerguson.github.io](https://github.com/JoshuaAFerguson/JoshuaAFerguson.github.io)** - Portfolio website
- **[ansible-runbooks](https://github.com/JoshuaAFerguson/ansible-runbooks)** - Ansible automation for infrastructure

## Repository Structure

```
templates/
├── README.md                    # This file
├── project-readme/
│   └── README.template.md       # Project README template
├── ansible-docs/
│   ├── RUNBOOKS_README.md       # Complete runbook documentation
│   └── PLAYBOOK_GUIDE.md        # Quick reference guide
├── k3s-template/
│   ├── README.md                # K3s deployment guide
│   └── config.example.yaml      # K3s cluster configuration
└── guides/
    └── SETUP_GUIDE.md           # GitHub setup guide
```

## Usage

### For New Projects

```bash
# Clone this repository
git clone https://github.com/JoshuaAFerguson/templates.git

# Copy the template you need
cp templates/project-readme/README.template.md ~/my-new-project/README.md

# Customize it
cd ~/my-new-project
vim README.md
```

### For Existing Projects

```bash
# Navigate to your project
cd ~/existing-project

# Copy and merge with existing README
cp ~/templates/project-readme/README.template.md README_NEW.md

# Review and merge sections you want
vimdiff README.md README_NEW.md
```

### For Ansible Projects

```bash
# Add documentation to your Ansible project
cd ~/ansible-project
mkdir -p docs
cp ~/templates/ansible-docs/* docs/

# Customize for your playbooks
vim docs/RUNBOOKS_README.md
```

### For K3s Clusters

```bash
# Copy K3s configuration template
cd ~/k3s-project
cp ~/templates/k3s-template/config.example.yaml config.yaml

# Customize for your environment
vim config.yaml

# Reference the README for deployment
cat ~/templates/k3s-template/README.md
```

## Customization Tips

1. **Start with Basics**: Fill in project name, description, installation
2. **Add Gradually**: Expand sections as your project grows
3. **Use Examples**: Include real code samples and commands
4. **Keep Updated**: Update docs when code changes
5. **Remove Unused Sections**: Delete sections that don't apply
6. **Add Badges**: Use shields.io for project badges
7. **Include Screenshots**: Visual aids improve documentation

## Best Practices

### README Documentation
- Write for your target audience
- Include quick start instructions
- Provide real examples, not placeholders
- Keep table of contents updated
- Use consistent formatting
- Include troubleshooting section

### Ansible Documentation
- Document all variables
- Include usage examples for each playbook
- Explain tags and their purposes
- Provide troubleshooting steps
- Document prerequisites clearly
- Include security considerations

## Examples

Projects with excellent documentation:

- [Kubernetes](https://github.com/kubernetes/kubernetes)
- [Terraform](https://github.com/hashicorp/terraform)
- [Ansible](https://github.com/ansible/ansible)
- [Docker](https://github.com/moby/moby)

## Contributing

Improvements to these templates are welcome!

1. Fork the repository
2. Create a feature branch
3. Make your improvements
4. Submit a pull request

## License

MIT License - See [LICENSE](LICENSE) file.

## Contact

**Joshua Ferguson**
- GitHub: [@JoshuaAFerguson](https://github.com/JoshuaAFerguson)
- Email: contact@joshua-ferguson.com

---

**Maintained by**: [Joshua Ferguson](https://github.com/JoshuaAFerguson)
