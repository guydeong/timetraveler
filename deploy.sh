#!/usr/bin/env bash
set -euo pipefail

# Usage: ./deploy.sh PROJECT_ID ZONE CLUSTER_NAME
PROJECT_ID=${1:-}
ZONE=${2:-us-west1}
CLUSTER=${3:-time-machine}

if [ -z "$PROJECT_ID" ]; then
  echo "Usage: $0 <GCP_PROJECT_ID> [ZONE] [CLUSTER_NAME]"
  exit 1
fi

# Build and push images
echo "Building and pushing Docker images to gcr.io/$PROJECT_ID"

docker build -f auth/Dockerfile -t gcr.io/$PROJECT_ID/tm-auth:latest .
docker push gcr.io/$PROJECT_ID/tm-auth:latest

docker build -f forecast_module/Dockerfile -t gcr.io/$PROJECT_ID/tm-forecast:latest .
docker push gcr.io/$PROJECT_ID/tm-forecast:latest

docker build -f frontend/Dockerfile -t gcr.io/$PROJECT_ID/tm-frontend:latest .
docker push gcr.io/$PROJECT_ID/tm-frontend:latest

# Authenticate kubectl to GKE and apply manifests
echo "Configuring kubectl for cluster '$CLUSTER' in project '$PROJECT_ID' zone '$ZONE'"
PROJECT=$PROJECT_ID
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

gcloud container clusters get-credentials "$CLUSTER" --project "$PROJECT" --zone "$ZONE"

# Create secret from local .env (do not commit .env to repo)
if [ -f ../.env ]; then
  echo "Creating/updating Kubernetes secret 'time-machine-env' from ../.env"
  kubectl create secret generic time-machine-env --from-env-file=../.env -o yaml --dry-run=client | kubectl apply -f -
else
  echo "Warning: ../.env not found. Please create the secret manually or place a .env at repo root."
fi

# Apply deployment
kubectl apply -f deployment.yaml
kubectl apply -f secret.yaml || true

echo "Deployment applied. Use 'kubectl get svc' to find external IP (LoadBalancer may take a few minutes)."
