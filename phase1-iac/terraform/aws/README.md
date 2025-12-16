# AWS Terraform README

## Overview

This Terraform configuration deploys a complete AWS infrastructure including:
- VPC with public and private subnets across multiple AZs
- Internet Gateway and NAT Gateway
- EKS (Elastic Kubernetes Service) cluster
- S3 bucket for storage
- RDS MySQL database

## Prerequisites

1. **AWS Account**: Set up using the guide in `../../documentation/aws-setup-guide.md`
2. **AWS CLI**: Configured with appropriate credentials
3. **Terraform**: Version >= 1.0 installed
4. **kubectl**: For interacting with the EKS cluster

## Configuration

### Step 1: Configure Variables

```bash
# Copy the example tfvars file
cp terraform.tfvars.example terraform.tfvars

# Edit the file with your values
nano terraform.tfvars
```

### Step 2: Update Database Password

**IMPORTANT**: Change the default database password in `terraform.tfvars`:

```hcl
db_password = "YourSecurePassword123!"
```

For production, use AWS Secrets Manager instead of hardcoding passwords.

## Deployment

### Initialize Terraform

```bash
terraform init
```

This will download the required provider plugins.

### Plan the Deployment

```bash
terraform plan
```

Review the planned changes carefully. This will show:
- Resources to be created
- Estimated costs (if using Terraform Cloud)
- Any potential issues

### Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted. This will create:
- 1 VPC
- 2 Public subnets
- 2 Private subnets
- 1 Internet Gateway
- 1 NAT Gateway
- Route tables
- 1 EKS cluster
- 1 EKS node group
- 1 S3 bucket
- 1 RDS MySQL instance

**Expected deployment time**: 15-20 minutes (EKS cluster takes the longest)

## Post-Deployment

### Configure kubectl

```bash
# Get the kubectl configuration command from outputs
terraform output configure_kubectl

# Or directly run:
aws eks update-kubeconfig --region us-east-1 --name devops-eks-cluster

# Verify connection
kubectl get nodes
```

### Access Outputs

```bash
# View all outputs
terraform output

# View specific output
terraform output eks_cluster_endpoint
terraform output s3_bucket_name
terraform output rds_endpoint
```

## Cost Optimization

### Current Configuration Costs

**Monthly estimate**: ~$151/month
- EKS control plane: $73/month
- t3.medium node: $30/month
- NAT Gateway: $33/month
- RDS db.t3.micro: $13/month
- S3 + other: ~$2/month

### Cost-Saving Options

1. **Disable NAT Gateway** (saves ~$33/month):
   ```hcl
   enable_nat_gateway = false
   ```

2. **Use Spot Instances** (saves ~$21/month):
   ```hcl
   capacity_type = "SPOT"
   ```

3. **Use smaller node** (saves ~$15/month):
   ```hcl
   node_instance_types = ["t3.small"]
   ```

4. **Stop RDS when not in use**:
   ```bash
   aws rds stop-db-instance --db-instance-identifier devops-multicloud-dev-db
   ```

### Free Tier Usage

- **S3**: Within 5GB free tier
- **RDS**: db.t3.micro is free tier eligible (750 hours/month for 12 months)
- **EKS**: Not included in free tier
- **VPC**: Free

## Accessing Resources

### S3 Bucket

```bash
# Get bucket name
BUCKET_NAME=$(terraform output -raw s3_bucket_name)

# Upload a file
aws s3 cp file.txt s3://$BUCKET_NAME/

# List files
aws s3 ls s3://$BUCKET_NAME/
```

### RDS Database

```bash
# Get database endpoint
DB_ENDPOINT=$(terraform output -raw rds_endpoint)

# Connect to database (requires MySQL client)
mysql -h $DB_ENDPOINT -u admin -p
```

### EKS Cluster

```bash
# Get cluster info
kubectl cluster-info

# Deploy a sample application
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get the LoadBalancer URL
kubectl get svc nginx
```

## Cleanup

### Destroy All Resources

```bash
terraform destroy
```

**WARNING**: This will delete:
- All Kubernetes workloads
- All data in S3 (if versioning is enabled, versions will remain)
- All data in RDS (unless `skip_final_snapshot = false`)
- All networking infrastructure

Type `yes` when prompted.

### Selective Resource Deletion

```bash
# Delete only the node group
terraform destroy -target=aws_eks_node_group.main

# Delete only the database
terraform destroy -target=aws_db_instance.main
```

## Troubleshooting

### Issue: EKS Cluster Creation Failed

```bash
# Check IAM permissions
aws sts get-caller-identity

# Ensure your user has Administrator Access or EKS-specific permissions
```

### Issue: Cannot connect to kubectl

```bash
# Reconfigure kubectl
aws eks update-kubeconfig --region us-east-1 --name devops-eks-cluster --profile default

# Check AWS credentials
aws sts get-caller-identity
```

### Issue: NAT Gateway Timeout

This is usually temporary. Wait a few minutes and try again:

```bash
terraform apply -refresh=true
```

### Issue: RDS Creation Slow

RDS instances typically take 10-15 minutes to create. This is normal.

### Issue: Terraform State Lock

If Terraform crashes, the state may remain locked:

```bash
# If using S3 backend with DynamoDB locking
# Manually remove the lock from DynamoDB table
```

## State Management

### Local State (Default)

State is stored in `terraform.tfstate` file. **Do not commit this to Git!**

### Remote State (Recommended for Teams)

Configure S3 backend:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "aws/terraform.tfstate"
    region = "us-east-1"
    
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}
```

## Security Best Practices

1. **Never commit** `terraform.tfstate` or `terraform.tfvars` to Git
2. **Use AWS Secrets Manager** for database passwords
3. **Enable MFA** on AWS root account
4. **Use IAM roles** instead of access keys when possible
5. **Enable CloudTrail** for audit logging
6. **Review security groups** regularly
7. **Enable S3 encryption** (already configured)
8. **Use private subnets** for databases (already configured)

## Integration with Other Tools

### Ansible Integration

Outputs from this Terraform configuration can be used in Ansible:

```bash
# Export outputs to Ansible vars
terraform output -json > ../../../ansible/terraform_outputs.json
```

### CI/CD Integration

Add to `.github/workflows` or Jenkins:

```bash
terraform init -backend-config="key=prod/terraform.tfstate"
terraform plan -out=tfplan
terraform apply tfplan
```

## Additional Resources

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

## Support

For issues:
1. Check AWS Service Health Dashboard
2. Review Terraform logs: `TF_LOG=DEBUG terraform apply`
3. Check AWS CloudTrail for API errors
4. Review this project's documentation

## License

MIT License - See LICENSE file for details
