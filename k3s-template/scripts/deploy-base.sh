#!/usr/bin/env bash
# Base K3s stack deployment script
# Deploys core infrastructure: namespaces, networking, storage, monitoring

set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== K3s Base Stack Deployment ==="
echo "Root directory: $ROOT_DIR"
echo

# Step 1: Create namespaces
echo "[1/4] Creating namespaces..."
kubectl apply -f "$ROOT_DIR/cluster/namespaces.yaml"
echo "✓ Namespaces created"
echo

# Step 2: Deploy networking (MetalLB, Ingress)
echo "[2/4] Deploying networking stack..."
kubectl apply -f "$ROOT_DIR/networking/metallb.yaml"
kubectl wait --for=condition=ready pod -l app=metallb -n metallb-system --timeout=120s || true
echo "✓ Networking deployed"
echo

# Step 3: Deploy storage (if configured)
echo "[3/4] Deploying storage..."
if [ -f "$ROOT_DIR/storage/longhorn.yaml" ]; then
    kubectl apply -f "$ROOT_DIR/storage/longhorn.yaml"
    echo "✓ Longhorn storage deployed"
elif [ -f "$ROOT_DIR/storage/nfs-provisioner.yaml" ]; then
    kubectl apply -f "$ROOT_DIR/storage/nfs-provisioner.yaml"
    echo "✓ NFS provisioner deployed"
else
    echo "ℹ Using K3s default local-path provisioner"
fi
echo

# Step 4: Apply base kustomization
echo "[4/4] Applying base kustomization..."
kubectl apply -k "$ROOT_DIR"
echo "✓ Base kustomization applied"
echo

echo "=== Base Deployment Complete ==="
echo
echo "Check cluster status with:"
echo "  kubectl get nodes"
echo "  kubectl get pods -A"
echo "  kubectl get svc -A"
echo
echo "Monitor resource usage:"
echo "  kubectl top nodes"
echo "  kubectl top pods -A"
