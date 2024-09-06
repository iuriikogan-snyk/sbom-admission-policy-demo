#!/usr/bin/env bash 
set -eou pipefail
IFS=$'\t'

# Function to print the usage information and exit the script with a non-zero status
function print_usage {
    echo "Usage: bash deploy.sh"
    echo "$*"
    exit 1
}

# shellcheck source=/scripts/setenv.sh
. ./scripts/setenv.sh
# shellcheck source=/scripts/prepare.sh
. ./scripts/prepare.sh

## Deploy kind with no CNI and ingress ports mappings / node-labels

# shellcheck source=./scripts/kind-ingress.yaml
kind create cluster --name "$CLUSTER_NAME" --config ./manifests/kind-ingress.yaml --silent
echo "creating kind cluster"

## deploy the Calico CNI

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml

echo 'waiting for calico pods to become ready....' 
kubectl wait --for=condition=ready pod -l k8s-app=calico-node -A --timeout=90s

## Deploy gatekeeper
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts

helm install gatekeeper/gatekeeper  \
    --name-template=gatekeeper \
    --namespace gatekeeper-system --create-namespace \
    --set enableExternalData=true \
    --set validatingWebhookTimeoutSeconds=5 \
    --set mutatingWebhookTimeoutSeconds=2 \
    --set externaldataProviderResponseCacheTTL=10s