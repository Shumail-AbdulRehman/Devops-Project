# Google Cloud Platform (GCP) Free Tier Setup Guide

## Overview

This guide walks you through setting up a Google Cloud Platform account with $300 free credits and access to always-free resources.

## Prerequisites

- Google account (Gmail or Google Workspace)
- Credit/debit card for verification
- Phone number for verification
- Valid billing address

## Step 1: Create GCP Account

1. **Visit GCP**: Go to [cloud.google.com/free](https://cloud.google.com/free)
2. **Click "Get started for free"**
3. **Sign in** with your Google account or create one

## Step 2: Account Setup

1. **Choose Account Type**: Personal or Business
2. **Country Selection**: Select your country
3. **Terms of Service**: Read and accept the terms

4. **Billing Information**:
   - Enter credit/debit card details
   - Card is verified but not charged during free trial
   - $1 verification charge may appear (refunded)

5. **Complete Registration**: Click "Start my free trial"

## Step 3: Access Google Cloud Console

1. **Navigate to Console**: Go to [console.cloud.google.com](https://console.cloud.google.com)
2. **Dashboard**: Explore the GCP Console interface
3. **Free Trial Status**: Check remaining credits at the top

## Step 4: Create a Project

```bash
# In the Cloud Console, click on the project dropdown
# Click "New Project"
# Project name: devops-multicloud
# Organization: (leave as default for personal account)
# Location: (leave as default or select your organization)
# Click "Create"
```

## Step 5: Enable Required APIs

```bash
# Navigate to "APIs & Services" > "Library"
# Enable the following APIs:
# - Compute Engine API
# - Kubernetes Engine API
# - Cloud Storage API
# - Cloud SQL Admin API
# - Cloud Resource Manager API
# - IAM API
```

Or use gcloud CLI:

```bash
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
```

## Step 6: Install Google Cloud SDK

### Linux Installation

```bash
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update and install
sudo apt-get update && sudo apt-get install google-cloud-cli

# Verify installation
gcloud --version
```

### Alternative: Script Installation

```bash
# Download and run the install script
curl https://sdk.cloud.google.com | bash

# Restart shell
exec -l $SHELL

# Verify
gcloud --version
```

## Step 7: Initialize gcloud CLI

```bash
# Initialize gcloud
gcloud init

# Follow the prompts:
# 1. Login to your Google account (browser opens)
# 2. Select or create a project
# 3. Configure default compute region and zone

# Recommended settings:
# Region: us-central1
# Zone: us-central1-a

# Verify configuration
gcloud config list
```

## Step 8: Configure Authentication for Terraform

```bash
# Set your project ID
export PROJECT_ID="devops-multicloud"

# Set project
gcloud config set project $PROJECT_ID

# Create a service account for Terraform
gcloud iam service-accounts create terraform-sa \
  --description="Service account for Terraform" \
  --display-name="Terraform Service Account"

# Get the service account email
export SA_EMAIL="terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com"

# Grant necessary roles
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create ~/terraform-gcp-key.json \
  --iam-account=${SA_EMAIL}

# Set environment variable
export GOOGLE_APPLICATION_CREDENTIALS="$HOME/terraform-gcp-key.json"

# Add to ~/.bashrc or ~/.zshrc
echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/terraform-gcp-key.json"' >> ~/.bashrc
```

## Step 9: Verify Configuration

```bash
# Test gcloud authentication
gcloud auth list

# Test service account
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# List projects
gcloud projects list

# Check compute zones
gcloud compute zones list

# Check current project
gcloud config get-value project
```

## GCP Free Tier Resources Used in This Project

### Free Trial Credits
- **$300 credit** for 90 days
- No automatic billing after trial ends
- Must manually upgrade to paid account

### Always Free Tier (After Trial)

#### Compute
- **Compute Engine**: 1 non-preemptible e2-micro VM instance per month (US regions)
- **Cloud Functions**: 2 million invocations per month
- **Cloud Run**: 2 million requests per month

#### Storage
- **Cloud Storage**: 5 GB standard storage per month
- **Persistent Disk**: 30 GB standard per month

#### Networking
- **Egress**: 1 GB from North America to all regions per month
- **Cloud Load Balancing**: Free tier available

#### Database
- **Cloud Firestore**: 1 GB storage
- **Cloud SQL**: Not included in always-free (but covered by trial credits)

#### Container & Orchestration
- **GKE**: $0.10 per cluster per hour (covered by trial credits)

## Important Notes

### Avoid Unexpected Charges

1. **Monitor Spending**:
   ```bash
   # Check billing in Cloud Console
   # Billing > Overview
   # Set up budget alerts
   ```

2. **Set Up Budget Alerts**:
   - Navigate to Billing > Budgets & alerts
   - Create budget
   - Set amount: $50 (or desired amount)
   - Set alert thresholds: 50%, 90%, 100%

3. **Enable Billing Export**:
   ```bash
   # Export billing data to BigQuery for analysis
   # Billing > Billing export
   ```

4. **Clean Up Resources**:
   ```bash
   # Always destroy resources when done
   terraform destroy
   
   # Or delete project entirely
   gcloud projects delete $PROJECT_ID
   ```

### Free Tier Limits to Watch

- **GKE Autopilot**: More cost-effective than standard GKE
- **Cloud NAT**: Costs apply ($0.045/hour per gateway)
- **External IP addresses**: $0.004-0.005 per hour when not attached to running VM
- **Load Balancers**: Costs vary by type
- **Cloud SQL**: Not in always-free tier

### Cost-Saving Tips

1. **Use e2-micro instances** (always-free eligible in US regions)
2. **Use preemptible VMs** for non-critical workloads (up to 80% discount)
3. **Use GKE Autopilot** instead of Standard (optimized costs)
4. **Stop instances** when not in use:
   ```bash
   gcloud compute instances stop INSTANCE_NAME
   ```
5. **Use committed use discounts** for production workloads
6. **Delete unattached persistent disks**
7. **Use Cloud Storage lifecycle policies** to move old data to cheaper storage classes

## Resource Naming Conventions

GCP naming requirements:

```bash
# Instance names: lowercase, hyphens, numbers
devops-vm-instance-1

# Bucket names: globally unique, lowercase, hyphens, numbers
devops-multicloud-bucket-001

# GKE cluster: lowercase, hyphens
devops-gke-cluster

# Network: lowercase, hyphens
devops-vpc-network
```

## Regional Considerations

### Recommended Regions

- **us-central1** (Iowa) - Always-free tier eligible, lowest cost
- **us-east1** (South Carolina) - Good alternative
- **europe-west1** (Belgium) - For EU compliance
- **asia-south1** (Mumbai) - For Asian projects

### Check Region/Zone Availability

```bash
# List all regions
gcloud compute regions list

# List zones in a specific region
gcloud compute zones list --filter="region:us-central1"

# Check quotas
gcloud compute project-info describe --project=$PROJECT_ID
```

## Quotas

Check and manage quotas:

```bash
# View quotas
gcloud compute project-info describe --project=$PROJECT_ID

# Common quotas to watch:
# - CPUs (default: 24-72 depending on region)
# - In-use IP addresses
# - Persistent disk size
# - GKE clusters per project (default: varies)

# Request quota increase through Cloud Console:
# IAM & Admin > Quotas
```

## Troubleshooting

### Issue: API Not Enabled
```bash
# Enable required API
gcloud services enable <api-name>.googleapis.com

# List enabled services
gcloud services list --enabled
```

### Issue: Authentication Failed
```bash
# Re-authenticate
gcloud auth login

# Activate service account
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
```

### Issue: Permission Denied
```bash
# Check IAM permissions
gcloud projects get-iam-policy $PROJECT_ID

# Add necessary role
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:your-email@gmail.com" \
  --role="roles/editor"
```

### Issue: Quota Exceeded
```bash
# Check quota usage
gcloud compute regions describe us-central1

# Request increase through console or support ticket
```

## Security Best Practices

1. **Enable 2-Factor Authentication** on Google account
2. **Use Service Accounts** for applications (not user credentials)
3. **Principle of Least Privilege**: Grant minimum necessary permissions
4. **VPC Service Controls**: Protect sensitive data
5. **Enable Cloud Audit Logs**: Track all API calls
6. **Use Secret Manager**: Store sensitive data securely
7. **Enable Binary Authorization**: For GKE security
8. **Regular Security Scans**: Use Security Command Center (free tier available)

## Organization Policies

For better governance:

```bash
# Set organization policies (if you have an organization)
# Restrict public IP addresses
# Enforce uniform bucket-level access
# Require OS Login
```

## GCP-Specific Features

### Cloud Shell

Free browser-based shell with 5 GB persistent storage:
- Pre-installed tools (gcloud, terraform, kubectl, etc.)
- Free for up to 50 hours per week
- Access from Cloud Console

### Cloud Build

Free tier includes:
- 120 build-minutes per day
- Great for CI/CD pipelines

## Next Steps

Once your GCP account is configured:

1. Review the Terraform code in `terraform/gcp/`
2. Update `terraform.tfvars` with your project ID
3. Initialize Terraform: `terraform init`
4. Plan deployment: `terraform plan`
5. Apply configuration: `terraform apply`

## Additional Resources

- [GCP Free Tier](https://cloud.google.com/free)
- [GCP Documentation](https://cloud.google.com/docs)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)

## Support

For GCP-related issues:
- Google Cloud Support
- Stack Overflow (tag: google-cloud-platform)
- GCP Community Slack
- Google Cloud Community forums
