# Artifact Management Strategy
## Container Images, Dependencies, and Build Artifacts

**Date**: December 2025  
**Version**: 1.0  
**Project**: DevOps Multi-Cloud

---

## 1. Executive Summary

Effective artifact management is critical for maintaining build reproducibility, ensuring security, and optimizing CI/CD pipeline performance. This document outlines the strategy for managing artifacts across our multi-cloud DevOps infrastructure.

## 2. Artifact Types

### 2.1 Container Images

**Primary Artifacts**: Docker container images

**Storage Locations**:
- **Development**: Docker Hub or GitHub Container Registry (GHCR)
- **Staging**: AWS ECR, Azure ACR, or Google Artifact Registry
- **Production**: Private registries in each cloud provider

**Retention Policy**:
- Keep last 10 versions of each image
- Retain `latest`, `stable`, and semantic versioned tags
- Archive older images to cold storage after 90 days
- Delete untagged images after 7 days

### 2.2 Application Dependencies

**Types**:
- NPM packages (Node.js)
- Python packages (pip)
- System packages (apt, yum)

**Management**:
- Use lock files (`package-lock.json`, `requirements.txt`)
- Cache dependencies in CI/CD runners
- Mirror critical dependencies in private repositories
- Scan for vulnerabilities with Trivy, Snyk

### 2.3 Build Artifacts

**Types**:
- Compiled binaries
- Test reports
- Code coverage reports
- Security scan results
- Infrastructure manifests

**Storage**: S3, Azure Blob Storage, or GCS buckets

## 3. Registry Strategy

### 3.1 Container Registry Selection

| Environment | Registry | Reason |
|-------------|----------|--------|
| Development | Docker Hub / GHCR | Free tier, public access |
| CI/CD | GHCR | Built-in GitHub integration |
| AWS Production | Amazon ECR | Native integration with EKS |
| Azure Production | Azure Container Registry | Native integration with AKS |
| GCP Production | Artifact Registry | Native integration with GKE |

### 3.2 Registry Configuration

**Security**:
- Enable image scanning at push time
- Require signed images (Docker Content Trust)
- Implement RBAC for access control
- Use service accounts with least privilege
- Enable audit logging

**Performance**:
- Use registry mirrors/proxies for frequently pulled images
- Enable multi-region replication
- Implement geo-distributed caches

## 4. Naming and Tagging Strategy

### 4.1 Image Naming Convention

```
<registry>/<organization>/<project>/<component>:<tag>
```

**Examples**:
```
ghcr.io/myorg/devops-multicloud/sample-app:v1.2.3
ghcr.io/myorg/devops-multicloud/sample-app:main-abc123f
ghcr.io/myorg/devops-multicloud/sample-app:pr-42
```

### 4.2 Tagging Strategy

**Semantic Versioning**:
- `v<major>.<minor>.<patch>` (e.g., `v1.2.3`)
- `v<major>.<minor>` (e.g., `v1.2`)
- `v<major>` (e.g., `v1`)

**Branch-based Tags**:
- `main-<short-sha>` for main branch
- `develop-<short-sha>` for develop branch
- `pr-<number>` for pull requests

**Special Tags**:
- `latest` - most recent stable build
- `stable` - last production deployment
- `canary` - canary deployment version
- `<date>-<sha>` - timestamp-based (e.g., `20250101-abc123f`)

**Never Use**:
- Mutable tags in production (except `latest` for development)
- Tags without version or commit reference

## 5. Artifact Lifecycle Management

### 5.1 Retention Policies

**Container Images**:
```yaml
Development:
  retention_days: 30
  max_versions: 10
  
Staging:
  retention_days: 90
  max_versions: 20
  
Production:
  retention_days: 365
  max_versions: 50
```

**Build Artifacts**:
```yaml
Test Reports:
  retention_days: 90
  
Code Coverage:
  retention_days: 90
  
Security Scans:
  retention_days: 180
  
Infrastructure State:
  retention_days: 365 (with versioning)
```

### 5.2 Cleanup Automation

**Automated Cleanup Script** (runs daily):

```bash
#!/bin/bash
# Cleanup old container images

# Delete untagged images older than 7 days
docker images -f "dangling=true" -q | xargs -r docker rmi

# Delete images older than retention period
# Implementation varies by registry
```

**Registry-specific Cleanup**:

```yaml
# ECR Lifecycle Policy
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

## 6. Security and Compliance

### 6.1 Image Scanning

**Scan Points**:
1. **On Build**: Scan immediately after build
2. **On Push**: Scan before pushing to registry
3. **Scheduled**: Daily scans of existing images
4. **On Pull**: Admission control in Kubernetes

**Tools**:
- Trivy for vulnerability scanning
- Clair for static analysis
- Anchore for policy enforcement

**Policy**:
- Block images with CRITICAL vulnerabilities
- Warn on HIGH vulnerabilities
- Track MEDIUM and LOW for awareness

### 6.2 Image Signing

**Use Cosign or Notary to sign images**:

```bash
# Sign image
cosign sign ghcr.io/myorg/app:v1.0.0

# Verify image
cosign verify ghcr.io/myorg/app:v1.0.0
```

**Kubernetes Admission Policy**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    container.apparmor.security.beta.kubernetes.io/app: runtime/default
spec:
  containers:
  - name: app
    image: ghcr.io/myorg/app:v1.0.0
    # Only allow signed images
```

### 6.3 Access Control

**AWS ECR**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789:role/EKSNodeRole"
      },
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
    }
  ]
}
```

**Azure ACR**:
```bash
# Assign role to AKS cluster
az aks update -n myAKS -g myRG --attach-acr myACR
```

**GCP Artifact Registry**:
```bash
# Grant GKE service account access
gcloud artifacts repositories add-iam-policy-binding myrepo \
  --location=us-central1 \
  --member=serviceAccount:my-gke-sa@project.iam.gserviceaccount.com \
  --role=roles/artifactregistry.reader
```

## 7. Caching and Performance

### 7.1 Build Cache

**Docker Build Cache**:
```dockerfile
# Use BuildKit cache mounts
RUN --mount=type=cache,target=/root/.npm \
    npm install
```

**CI/CD Cache**:
```yaml
# GitHub Actions
- uses: actions/cache@v3
  with:
    path: ~/.npm
    key: ${{ runner.os }}-npm-${{ hashFiles('**/package-lock.json') }}
```

### 7.2 Registry Cache

**Pull-through Cache**:
- Cache upstream Docker Hub images
- Reduce external bandwidth
- Improve pull performance

**Configuration Example (Docker)**:
```yaml
registry_mirrors:
  - http://my-registry-mirror:5000
```

## 8. Dependency Management

### 8.1 Package Mirroring

**NPM**:
```bash
# Use private registry
npm config set registry https://registry.internal.company.com
```

**Lock File Strategy**:
- Commit lock files to version control
- Use `npm ci` instead of `npm install` in CI
- Regularly update and audit dependencies

### 8.2 Vulnerability Management

**Automated Scanning**:
```bash
# Scan Node.js dependencies
npm audit

# Scan with Snyk
snyk test

# Scan with OWASP Dependency-Check
dependency-check --project myapp --scan .
```

**Update Policy**:
- Critical vulnerabilities: Update within 24 hours
- High vulnerabilities: Update within 1 week
- Medium/Low: Scheduled maintenance windows

## 9. Disaster Recovery

### 9.1 Backup Strategy

**Registry Backup**:
- Replicate images across multiple regions
- Export critical images to S3/Blob Storage
- Maintain offline backups of production images

**Terraform State Backup**:
```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state-backup"
    key    = "state/terraform.tfstate"
    versioning = true
  }
}
```

### 9.2 Recovery Procedures

**Image Recovery**:
1. Identify last known good image
2. Pull from backup registry
3. Re-tag and push to primary registry
4. Rollback deployments if necessary

## 10. Monitoring and Auditing

### 10.1 Metrics to Track

- Number of images in registry
- Image pull frequency
- Storage usage (GB)
- Build artifact size trends
- Vulnerability count per image
- Image age distribution

### 10.2 Audit Logging

**Enable audit logs for**:
- Image pushes/pulls
- Tag operations
- Permission changes
- Scan results

**Log Retention**: 365 days minimum

## 11. Cost Optimization

### 11.1 Storage Costs

**Strategies**:
- Aggressive cleanup of old images
- Compress layers in multi-stage builds
- Use smaller base images (Alpine Linux)
- Enable lifecycle policies

**Cost Comparison** (100GB storage):
| Registry | Monthly Cost |
|----------|--------------|
| Docker Hub | Free (public) |
| GHCR | Free (public) |
| AWS ECR | ~$10 |
| Azure ACR | ~$5 (Basic tier) |
| GCP Artifact Registry | ~$10 |

### 11.2 Transfer Costs

- Use regional registries
- Minimize cross-region transfers
- Cache images on nodes
- Use registry mirrors

## 12. Implementation Checklist

- [ ] Select primary registry per environment
- [ ] Configure tagging strategy
- [ ] Implement retention policies
- [ ] Enable image scanning
- [ ] Set up RBAC/IAM policies
- [ ] Configure backup and replication
- [ ] Implement caching strategy
- [ ] Set up monitoring and alerts
- [ ] Document procedures
- [ ] Train team on artifact management

## 13. Conclusion

Effective artifact management requires:
1. **Standardization**: Consistent naming and tagging
2. **Automation**: Automated cleanup and scanning
3. **Security**: Scanning, signing, and access control
4. **Performance**: Caching and optimization
5. **Reliability**: Backup and disaster recovery

Regular review and updates of this strategy ensure alignment with evolving organizational needs and cloud provider capabilities.

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Next Review**: June 2026
