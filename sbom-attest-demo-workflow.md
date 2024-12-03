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
export IMAGE=iuriikogan/sbom-attest@sha256:4aab02c25f770611c8c4a28f6ba4562af2510c4bf0addfbd6b902422ba201b02
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
notation sign "docker.io/iuriikogan/sbom-attest:v1.0.0"
```

## Authenticate ORAS to docker

```bash
oras login docker.io
```

## Attach the SBOM to the image with ORAS

```bash
oras attach "docker.io/iuriikogan/sbom-attest:v1.0.0" \
--artifact-type application/spdx+json \
bom.spdx.json
```

## Inspect the Image

```bash
oras discover "docker.io/$IMAGE"
```

## take the SBOM_SHA from the output

```bash
export SBOM_SHA=sha256:f884d8c056698870b2dc8b0ebebeb38af45ab86c07a44aaccab4eeffef954a20 &&
export SIGNATURE_SHA=sha256:20cd649e4df45156333e5e7003353978b0d63ef6a9a2fae5cffed8d1bcc6496c
```

## Pull the SBOM to /artifacts dir

```bash
oras pull "docker.io/iuriikogan/sbom-attest@sha256:a03b0c5621b95d9a2d970d24cd74a31da28198295754f5f4dcbd8276b7e87a86" -o ./artifacts
```
