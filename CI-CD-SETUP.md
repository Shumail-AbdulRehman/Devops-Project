# CI/CD Pipeline Setup Guide

## 🚀 Your CI/CD Pipelines Are Ready!

This repository includes **both Jenkins and GitHub Actions** pipelines, fully configured and ready to use.

---

## ✅ GitHub Actions Setup (Recommended - Zero Infrastructure!)

### What's Included

The GitHub Actions workflow is located at: `.github/workflows/ci-cd-pipeline.yml`

**Pipeline Stages:**
1. ✅ Code Quality Check (SonarQube + ESLint)
2. ✅ Run Tests with Coverage
3. ✅ Build Docker Image
4. ✅ Security Scan (Trivy)
5. ✅ Push to GitHub Container Registry
6. ✅ Deploy to Kubernetes
7. ✅ Smoke Tests

### Activation Steps

**1. Enable GitHub Actions** (if not already enabled):
   - Go to: https://github.com/Shumail-AbdulRehman/Devops-Project/settings/actions
   - Under "Actions permissions", select "Allow all actions and reusable workflows"
   - Click "Save"

**2. Configure Secrets**:

Go to: https://github.com/Shumail-AbdulRehman/Devops-Project/settings/secrets/actions

Add these secrets:

| Secret Name | Value | Required For |
|-------------|-------|--------------|
| `SONAR_TOKEN` | Your SonarQube token | Code quality analysis |
| `SONAR_HOST_URL` | Your SonarQube server URL | Code quality analysis |
| `KUBECONFIG` | Your Kubernetes config file | Deployment |
| `SLACK_WEBHOOK` | Slack webhook URL (optional) | Notifications |

**3. Trigger the Pipeline**:

The pipeline runs automatically on:
- Push to `main` or `develop` branch
- Pull requests to `main`
- Manual trigger (workflow_dispatch)

To manually trigger:
```bash
# Make any change and push
git add .
git commit -m "Trigger CI/CD pipeline"
git push origin main
```

Or use GitHub UI:
- Go to "Actions" tab
- Select "CI/CD Pipeline"
- Click "Run workflow"

**4. Monitor Pipeline**:
- Visit: https://github.com/Shumail-AbdulRehman/Devops-Project/actions

---

## 🔧 Jenkins Setup (For Self-Hosted Infrastructure)

### What's Included

The Jenkinsfile is located at the repository root: `Jenkinsfile`

**Pipeline Stages:**
1. ✅ Checkout
2. ✅ Code Quality (SonarQube)
3. ✅ Quality Gate
4. ✅ Run Tests
5. ✅ Build Docker Image
6. ✅ Security Scan (Trivy)
7. ✅ Push to Registry
8. ✅ Deploy to Kubernetes
9. ✅ Verify Deployment

### Setup Steps

**1. Install Jenkins**:
```bash
# On Ubuntu/Debian
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install jenkins
```

**2. Install Required Plugins**:
- Pipeline
- Docker Pipeline
- Kubernetes
- SonarQube Scanner
- Git

**3. Configure Tools in Jenkins**:

Go to: `Manage Jenkins` → `Global Tool Configuration`

- **SonarQube Scanner**: Add SonarQube scanner installation
- **Docker**: Configure Docker installation

**4. Configure Credentials**:

Go to: `Manage Jenkins` → `Manage Credentials`

Add these credentials:

| ID | Type | Description |
|----|------|-------------|
| `dockerhub-credentials` | Username/Password | Docker registry credentials |
| `sonarqube-token` | Secret text | SonarQube authentication token |
| `kubeconfig` | Secret file | Kubernetes configuration |

**5. Create Pipeline Job**:
- Click "New Item"
- Name: "DevOps-Multi-Cloud-Pipeline"
- Type: "Pipeline"
- Pipeline definition: "Pipeline script from SCM"
- SCM: Git
- Repository URL: `https://github.com/Shumail-AbdulRehman/Devops-Project.git`
- Script Path: `Jenkinsfile`

**6. Run the Pipeline**:
- Click "Build Now"
- Monitor in "Console Output"

---

## 📦 Sample Application

The pipelines build and deploy the Node.js application in `phase2-cicd/sample-app/`

### Local Testing

```bash
cd phase2-cicd/sample-app

# Install dependencies
npm install

# Run tests
npm test

# Run locally
npm start

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/api/info

# Build Docker image
docker build -t devops-sample-app:latest .

# Run container
docker run -p 3000:3000 devops-sample-app:latest
```

---

## 🔒 Security Scanning

Both pipelines include **Trivy** for vulnerability scanning.

### Install Trivy Locally

```bash
# Ubuntu/Debian
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Scan image
trivy image devops-sample-app:latest
```

---

## 📊 SonarQube Setup

### Option 1: SonarCloud (Recommended for GitHub Actions)

1. Go to: https://sonarcloud.io/
2. Sign in with GitHub
3. Create new organization
4. Add your repository
5. Get your token from: Account → Security → Generate Token
6. Add to GitHub Secrets as `SONAR_TOKEN`
7. Set `SONAR_HOST_URL` to `https://sonarcloud.io`

### Option 2: Self-Hosted SonarQube (For Jenkins)

```bash
# Run SonarQube with Docker
docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:latest

# Access at: http://localhost:9000
# Default credentials: admin / admin
```

---

## 🎯 Pipeline Execution Flow

```
┌─────────────────┐
│   Code Push     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Code Quality   │ ← SonarQube Analysis
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Run Tests     │ ← Jest/Mocha Tests
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Docker Build   │ ← Multi-stage Build
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Security Scan   │ ← Trivy Scanning
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Push Image     │ ← To Registry
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Deploy to K8s  │ ← Rolling Update
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Verify      │ ← Health Checks
└─────────────────┘
```

---

## 🚀 Quick Start Checklist

### For GitHub Actions:
- [ ] Enable Actions in repository settings
- [ ] Add required secrets (SONAR_TOKEN, KUBECONFIG)
- [ ] Push a commit to trigger pipeline
- [ ] Monitor in Actions tab

### For Jenkins:
- [ ] Install Jenkins and plugins
- [ ] Configure tools (SonarQube, Docker)
- [ ] Add credentials
- [ ] Create pipeline job
- [ ] Run build

---

## 📈 Monitoring & Metrics

### GitHub Actions
- View runs: https://github.com/Shumail-AbdulRehman/Devops-Project/actions
- Download artifacts from completed runs
- Check deployment status in Actions tab

### Jenkins
- Blue Ocean UI for visualization
- Pipeline trends and statistics
- Build history and logs

---

## 🆘 Troubleshooting

### Common Issues

**GitHub Actions:**
- **"Permission denied"**: Check KUBECONFIG secret is valid
- **"SonarQube connection failed"**: Verify SONAR_TOKEN and SONAR_HOST_URL
- **"Docker build failed"**: Check Dockerfile syntax

**Jenkins:**
- **"Docker not found"**: Install Docker plugin and configure tool
- **"Kubernetes connection failed"**: Verify kubeconfig credentials
- **"SonarQube unreachable"**: Check SonarQube server is running

### Getting Help
- Check pipeline logs for detailed error messages
- Review documentation in `phase2-cicd/documentation/`
- Consult research papers for best practices

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [SonarQube Documentation](https://docs.sonarqube.org/)

---

## ✅ Your Project Meets All Requirements

**Phase 2 Deliverables - Complete:**
✅ Jenkins pipeline with Groovy DSL  
✅ GitHub Actions workflows  
✅ Multi-stage pipeline (Quality, Build, Scan, Test, Deploy)  
✅ Code quality (SonarQube)  
✅ Container building (Docker)  
✅ Security scanning (Trivy)  
✅ Automated testing  
✅ Artifact management strategy  
✅ CI/CD tools comparison  
✅ Performance metrics  

**Everything is production-ready and properly documented!** 🎉
