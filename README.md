## SBOM Admission Policy Demo

This demo showcases how to use [Snyk](snyk.io) container sbom feature alongside Gatekeeper (OPA) and Ratify to ensure that only images with valid SBOMs are deployed to a Kubernetes environments.

The [snyk container sbom](https://docs.snyk.io/snyk-cli/commands/container-sbom) feature generates an SBOM for a container image.

Currently the only supported format is SPDX v2.3 (JSON).

An SBOM can be generated for operating system dependencies as well as [application dependencies within the image](https://docs.snyk.io/scan-with-snyk/snyk-container/use-snyk-container/detect-application-vulnerabilities-in-container-images)

## Workflow Diagram
![image](https://github.com/user-attachments/assets/acffd15a-ee39-4a36-9502-7de6d1b0ef1d)

## Quick Start

### If you have a cluster

1. Edit the `setenv.sh` file to set the required environment variables or ensure they are available in your environment (best practice):

```bash
vi setenv.sh
```

2. Deploy the demo:

```bash
./scripts/deploy.sh --demo
```

3. Run a verified deployment:

```bash
kubectl run verified -n sbom-demo --image=iuriikogan/snyk-juice-shop:linux-amd64
```

Expected Output: `pod/verified created`
Logs for the ratify pod in gatekeeper-system namespace will show:
```markdown
{
    "subject": "docker.io/iuriikogan/snyk-juice-shop@sha256:97e7c99eb657bcc631232b747ff7904b2fea40b7301b7c4658e62f6ec6a82dfd",
    "referenceDigest": "sha256:05149e16a75f5667d31906b1aa595c9dca6947c79a3de904292b513cbc6ea400",
    "artifactType": "application/spdx+json",
    "verifierReports": [
    {
        "isSuccess": true,
        "message": "SBOM verification success. No license or package violation found.",
        "name": "verifier-sbom",
        "verifierName": "verifier-sbom",
        "type": "sbom",
        "verifierType": "sbom",
        "extensions": {
        "creationInfo": {
            "created": "2024-09-23T13:43:58Z",
            "creators": [
            "Tool: Snyk SBOM Export API v1.98.0",
            "Organization: Snyk"
            ],
            "licenseListVersion": "3.19"
        }
        }
    }
    ],
    "nestedReports": []
}
```

4. Test the unverified deployment:

```bash
kubectl run unverified -n sbom-demo --image=iuriikogan/unverified:latest
```

Expected Output:

```Markdown
Error from server (Forbidden): admission webhook "validation.gatekeeper.sh" denied the request: [ratify-constraint] Subject failed verification: docker.io/iuriikogan/unverified@sha256:97396efd3dc2971804148d21cc6a3d532cfd3212c25c10d76664eb8fc56f2878`
```

5. Clean up the environment:
```bash
./scripts/destroy.sh [--kind]
```

### If you don't have a cluster

1. Edit the `setenv.sh` file to set the required environment variables:

```bash
vi setenv.sh
```

2. Deploy the demo:

```bash
./scripts/deploy.sh --all
```

**Continue with step 3 above.**

## Why should I care about SBOMs?

Software Bill of Materials (SBOMs) provide a detailed list of components within software, offering transparency and accountability. As regulatory frameworks like the NIS Directive (Network and Information Systems) in Europe, the Digital Operational Resilience Act (DORA), and various other cybersecurity standards grow increasingly stringent, ensuring compliance is critical for businesses operating in regulated sectors.

SBOMs help achieve compliance by enhancing the visibility of software components, including open-source dependencies, which is vital for reporting, audit trails, and maintaining operational resilience. By attaching the SBOM as an artifact to an OCI image and enforcing policies that only allow the deployment of images with SBOMs, organizations can meet regulatory requirements around software transparency and vulnerability management.

**Regulatory Benefits:**
NIS Directive: Ensures critical infrastructure operators follow cybersecurity best practices by mandating security incident reporting and proactive risk management, including software transparency.

**DORA:** Focuses on the resilience of the financial sector's IT systems by requiring comprehensive oversight and secure software deployment practices, including the use of SBOMs for tracking software vulnerabilities.

**Other Cybersecurity Regulations:** Similar regulations (e.g., Executive Order 14028 in the U.S.) require the adoption of SBOMs to improve software supply chain security.

## Why Should I integrate SBOMs into my container deployment pipelines/enforce SBOMs via policy?

By integrating SBOMs into your Kubernetes deployment pipeline, you not only ensure that each image has passed critical security checks, but also provide auditable evidence that your organization adheres to compliance standards. This ensures that vulnerabilities are identified before deployment, protecting against attacks and fulfilling reporting requirements during security audits.

Using policy enforcement tools like Gatekeeper and Ratify enables automated compliance checks, ensuring that non-compliant images (those without SBOMs or with unresolved vulnerabilities) are not deployed. This setup supports both real-time compliance enforcement and audit-readiness, making it easier to demonstrate adherence to regulatory frameworks during audits and reviews.

## What is Gatekeeper?

Gatekeeper is a policy enforcement tool for Kubernetes that ensures resources comply with organizational policies. It automates policy enforcement, which minimizes errors and enhances consistency by providing immediate feedback during development.

Kubernetes' policy enforcement is decoupled from its API server using admission controller webhooks that are triggered when resources are created, updated, or deleted. Gatekeeper acts as a validating and mutating webhook, enforcing Custom Resource Definitions (CRDs) defined by the Open Policy Agent (OPA), a powerful policy engine for cloud-native environments.

## What is Ratify?

Ratify, established in 2021, is an open-source verification engine that enables users to enforce policies by verifying container images and attestations, including SBOMs and vulnerability reports. Ratify offers a pluggable framework, allowing users to integrate custom verification plugins.

A common use case for Ratify is integrating it with Gatekeeper as a Kubernetes policy controller. Ratify serves as an external data provider for Gatekeeper, supplying verification data that Gatekeeper can enforce based on predefined policies.

[Learn more about Ratify and SBOM verification](https://ratify.dev/docs/plugins/verifier/sbom#sbom-with-license-and-package-validation).

## Prerequisites

Ensure the following tools are installed:


- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)
  
## Limitations
TODO
