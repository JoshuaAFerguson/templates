#!/usr/bin/env bash
# Generate Kubernetes secrets from environment file
# Load from .env file and create rendered secrets

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
RENDERED_DIR="${ROOT_DIR}/rendered"

# Source .env file if it exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: .env file not found at $ENV_FILE"
    echo "Please create one from .env.example"
    exit 1
fi

# Load environment variables
set -a
source "$ENV_FILE"
set +a

# Create rendered directory
mkdir -p "$RENDERED_DIR"

echo "=== Generating Kubernetes Secrets ==="
echo

# Generate database secret
echo "[1/5] Generating database credentials..."
cat > "$RENDERED_DIR/postgres-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: postgres-credentials
  namespace: data
type: Opaque
stringData:
  username: ${POSTGRES_USER:-postgres}
  password: ${POSTGRES_PASSWORD:-changeme}
  database: ${POSTGRES_DB:-app}
EOF
echo "✓ Database secret created"

# Generate S3/MinIO secret
echo "[2/5] Generating S3/MinIO credentials..."
cat > "$RENDERED_DIR/minio-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: minio-credentials
  namespace: storage
type: Opaque
stringData:
  accessKey: ${MINIO_ACCESS_KEY:-minioadmin}
  secretKey: ${MINIO_SECRET_KEY:-minioadmin}
EOF
echo "✓ S3/MinIO secret created"

# Generate Cloudflare tunnel secret (if configured)
if [ -n "${CF_TUNNEL_TOKEN:-}" ]; then
    echo "[3/5] Generating Cloudflare tunnel secret..."
    cat > "$RENDERED_DIR/cloudflared-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: cloudflare-tunnel
  namespace: networking
type: Opaque
stringData:
  token: ${CF_TUNNEL_TOKEN}
EOF
    echo "✓ Cloudflare tunnel secret created"
else
    echo "[3/5] Skipping Cloudflare tunnel secret (CF_TUNNEL_TOKEN not set)"
fi

# Generate monitoring credentials
echo "[4/5] Generating monitoring credentials..."
cat > "$RENDERED_DIR/grafana-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: grafana-admin
  namespace: monitoring
type: Opaque
stringData:
  admin-user: ${GRAFANA_ADMIN_USER:-admin}
  admin-password: ${GRAFANA_ADMIN_PASSWORD:-prom-operator}
EOF
echo "✓ Grafana secret created"

# Generate generic API keys
echo "[5/5] Generating API keys..."
cat > "$RENDERED_DIR/api-keys-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: api-keys
  namespace: default
type: Opaque
stringData:
  openai-api-key: ${OPENAI_API_KEY:-sk-dummy}
  slack-webhook: ${SLACK_WEBHOOK_URL:-https://hooks.slack.com/services/DUMMY}
EOF
echo "✓ API keys secret created"

echo
echo "=== Secret Generation Complete ==="
echo
echo "Generated secrets in: $RENDERED_DIR"
echo
echo "⚠️  SECURITY WARNING:"
echo "  - Never commit rendered/*.yaml files to version control"
echo "  - Add 'rendered/' to your .gitignore"
echo "  - Consider using SOPS or sealed-secrets for production"
echo
echo "Apply secrets with:"
echo "  kubectl apply -f $RENDERED_DIR/"
