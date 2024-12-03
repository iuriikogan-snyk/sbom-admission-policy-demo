# Demo workflow

## Prerequisites

ORAS, Notation and Snyk CLI installed, Docker running, REGISTRY_USERNAME variable is set

## Login to docker

```bash
docker login
```

## Build the Image

```bash
docker build -t "$REGISTRY_USERNAME/sbom-attest:v1.0.0" --platform=linux/amd64 . --push
```

## Take image digest and store as env var

```bash
docker inspect --format='{{index .RepoDigests 0}}' "docker.io/$REGISTRY_USERNAME/sbom-attest:v1.0.0"
```

```bash
export IMAGE=
```

## Create an SBOM

```bash
snyk container sbom "docker.io/$IMAGE" --format=spdx2.3+json > bom.spdx.json
```

## Authenticate Notation to Docker

```bash
notation login docker.io
```

## Generate a test key and self-signed certificate

```bash
notation cert generate-test --default "wabbit-networks.io"
```

## confirm the key and cert in the trust store

```bash
notation key ls && notation cert ls
```

## Sign the Image

```bash
notation sign "docker.io/$IMAGE"
```

## Authenticate ORAS to docker

```bash
oras login docker.io
```

## Attach the SBOM to the image with ORAS

```bash
oras attach "docker.io/$IMAGE" \
--artifact-type application/spdx+json \
bom.spdx.json
```

## Inspect the Image

```bash
oras discover "docker.io/$IMAGE"
```

## take the SBOM_SHA from the output

```bash
export SBOM_SHA=sha256:f8127e5d3477c0eb279a019d36504164f189e513d0740906f0d322129a0d21cc
```

## Pull the SBOM to /artifacts dir

```bash
oras pull "docker.io/$REGISTRY_USERNAME/sbom-attest@$SBOM_SHA" -o ./artifacts
```
