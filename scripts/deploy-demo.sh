#! /usr/bin/env bash
set -eou pipefail

# Function to print the usage information and exit the script with a non-zero status
function print_usage {
    echo "Usage: bash deploy-demo.sh"
    echo "$*"
    exit 1
}

## Deploy gatekeeper
echo "deploying gatekeeper"
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts

helm install gatekeeper/gatekeeper  \
    --name-template=gatekeeper \
    --namespace gatekeeper-system --create-namespace \
    --set enableExternalData=true \
    --set validatingWebhookTimeoutSeconds=5 \
    --set mutatingWebhookTimeoutSeconds=2 \
    --set externaldataProviderResponseCacheTTL=10s

kubectl create secret docker-registry ratify-regcred --namespace=gatekeeper-system \
    --docker-server="${REGISTRY_URL}" \
    --docker-username="${REGISTRY_USERNAME}" \
    --docker-password="${REGISTRY_PASSWORD}" \
    --docker-email="${REGISTRY_EMAIL}"

echo "deploying ratify"
# Deploy Ratify
helm repo add ratify https://ratify-project.github.io/ratify

# download the notary "erification certificate
curl -sSLO https://raw.githubusercontent.com/deislabs/ratify/main/test/testdata/notation.crt
# install ratify
helm install ratify \
    ratify/ratify --atomic \
    --namespace gatekeeper-system \
    --set-file notationCerts={./notation.crt} \
    --set featureFlags.RATIFY_CERT_ROTATION=true \
    --set policy.useRego=true \
    --set oras.authProviders.k8secretsEnabled=true \
    --set sbom.enabled=true \
    # --set sbom.maximumAge="24h"
    # --set sbom.notaryProjectSignatureRequired=true \
    # --set sbom.disallowedLicenses={"MPL"}
    # --set sbom.disallowedPackages[0].name={"busybox"}
    # --set vulnerabilityreport.enabled=true \
    # --set vulnerabilityreport.maximumAge="24h" \
    # --set vulnerabilityreport.notaryProjectSignatureRequired=true \
    # --set vulnerabilityreport.disallowedSeverities="{high,critical}"

kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=ratify -n gatekeeper-system --timeout=90s

echo "Deploying Gatekeeper Templates and Contrainsts, and Ratify Verifier"
kubectl apply -f ./manifests/resources/gatekeeper/
kubectl apply -f ./manifests/resources/ratify/
