# DevOps Multi-Cloud Project

A comprehensive DevOps project demonstrating Infrastructure as Code (IaC) across AWS, Azure, and GCP, along with modern CI/CD pipeline implementation.

## Project Structure

```
devops-multicloud-project/
├── phase1-iac/
│   ├── documentation/
│   │   ├── aws-setup-guide.md
│   │   ├── azure-setup-guide.md
│   │   ├── gcp-setup-guide.md
│   │   ├── iac-comparison-paper.md
│   │   └── cost-analysis.md
│   ├── terraform/
│   │   ├── aws/
│   │   ├── azure/
│   │   └── gcp/
│   └── ansible/
│       ├── inventory/
│       └── playbooks/
├── phase2-cicd/
│   ├── sample-app/
│   ├── jenkins/
│   ├── github-actions/
│   └── documentation/
├── docs/
└── README.md
```

## Phase 1 - Infrastructure as Code

### Multi-Cloud Terraform Infrastructure

- **AWS**: VPC, Subnets, Route Tables, EKS, S3, RDS
- **Azure**: VNet, Subnets, AKS, Blob Storage, SQL Database
- **GCP**: VPC, GKE, Cloud Storage, Cloud SQL

### Ansible Configuration Management

Automated configuration playbooks for:
- Docker installation
- User setup and management
- Kubernetes cluster configuration

## Phase 2 - CI/CD Pipelines

### Pipeline Features

- Code quality analysis (SonarQube)
- Container image building
- Security scanning (Trivy)
- Automated testing
- Image registry push
- Automated deployment

### Supported Tools

- Jenkins
- GitHub Actions

## Quick Start

### Prerequisites

- Cloud provider accounts (AWS, Azure, GCP)
- Terraform >= 1.0
- Ansible >= 2.9
- Docker
- kubectl

### Phase 1 - Deploy Infrastructure

```bash
# AWS Infrastructure
cd phase1-iac/terraform/aws
terraform init
terraform plan
terraform apply

# Azure Infrastructure
cd ../azure
terraform init
terraform plan
terraform apply

# GCP Infrastructure
cd ../gcp
terraform init
terraform plan
terraform apply
```

### Run Ansible Playbooks

```bash
cd phase1-iac/ansible

# Install Docker on target hosts
ansible-playbook -i inventory/hosts playbooks/install-docker.yml

# Setup users
ansible-playbook -i inventory/hosts playbooks/setup-users.yml

# Configure Kubernetes
ansible-playbook -i inventory/hosts playbooks/configure-k8s.yml
```

### Phase 2 - CI/CD Pipeline

#### Jenkins
```bash
# Copy Jenkinsfile to your repository
cp phase2-cicd/jenkins/Jenkinsfile <your-repo>/

# Configure Jenkins with required plugins:
# - SonarQube Scanner
# - Docker Pipeline
# - Kubernetes
```

#### GitHub Actions
```bash
# Copy workflow to your repository
cp phase2-cicd/github-actions/.github/workflows/ci-cd-pipeline.yml <your-repo>/.github/workflows/

# Configure GitHub Secrets:
# - DOCKER_USERNAME
# - DOCKER_PASSWORD
# - SONAR_TOKEN
```

## Documentation

All research papers and analysis documents are available in:
- `phase1-iac/documentation/` - IaC comparison and cost analysis
- `phase2-cicd/documentation/` - CI/CD tools comparison, artifact management, and performance metrics

## Security Considerations

- All sensitive data should be stored in environment variables or secret management services
- Enable MFA on all cloud accounts
- Use least privilege principle for IAM roles
- Regularly scan images for vulnerabilities
- Keep infrastructure code in version control

## Cost Optimization

- Use free tier resources where possible
- Implement auto-scaling policies
- Set up billing alerts
- Use spot/preemptible instances for non-critical workloads
- Clean up unused resources regularly

## Contributing

This project is designed for educational and demonstration purposes. Feel free to extend and customize for your needs.

## License

MIT License - Feel free to use this for learning and development purposes.
