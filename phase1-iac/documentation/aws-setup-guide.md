# AWS Free Tier Setup Guide

## Overview

This guide walks you through setting up an AWS Free Tier account for this DevOps project.

## Prerequisites

- Valid email address
- Credit/debit card (required for verification, but won't be charged for free tier usage)
- Phone number for verification

## Step 1: Create AWS Account

1. **Visit AWS**: Go to [aws.amazon.com](https://aws.amazon.com)
2. **Click "Create an AWS Account"**
3. **Enter Account Details**:
   - Email address
   - Password
   - AWS account name
4. **Select Account Type**: Choose "Personal" for this project
5. **Enter Contact Information**:
   - Full name
   - Phone number
   - Address

## Step 2: Payment Information

1. **Add Payment Method**: Enter credit/debit card details
2. **Verification**: AWS will charge $1 for verification (refunded immediately)
3. **Confirm**: Complete the payment information

## Step 3: Identity Verification

1. **Phone Verification**: 
   - Enter your phone number
   - Choose SMS or voice call
   - Enter the verification code received

## Step 4: Choose Support Plan

1. **Select Basic Support**: This is free and sufficient for this project
2. **Complete Sign Up**

## Step 5: Access AWS Management Console

1. **Sign In**: Use your root account credentials
2. **Navigate**: You'll see the AWS Management Console dashboard

## Step 6: Secure Your Root Account

### Enable MFA (Multi-Factor Authentication)

1. Go to **IAM** (Identity and Access Management)
2. Click on **Dashboard**
3. Under **Security Status**, expand "Activate MFA on your root account"
4. Click **Manage MFA**
5. Choose **Virtual MFA device**
6. Use Google Authenticator or Authy app to scan QR code
7. Enter two consecutive MFA codes

### Create IAM User

1. In IAM, go to **Users** → **Add user**
2. **User name**: `terraform-admin`
3. **Access type**: Check "Programmatic access"
4. **Permissions**: Attach existing policies directly
   - `AdministratorAccess` (for this project; use granular permissions in production)
5. **Download credentials**: Save the CSV file with Access Key ID and Secret Access Key
6. **Important**: Never commit these credentials to version control

## Step 7: Configure AWS CLI

```bash
# Install AWS CLI (if not already installed)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS CLI
aws configure

# Enter the following when prompted:
# AWS Access Key ID: [Your Access Key from CSV]
# AWS Secret Access Key: [Your Secret Key from CSV]
# Default region name: us-east-1
# Default output format: json
```

## Step 8: Verify Configuration

```bash
# Test AWS CLI
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDXXXXXXXXXXXXXXXXX",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/terraform-admin"
# }
```

## AWS Free Tier Resources Used in This Project

### Compute
- **EC2**: 750 hours per month of t2.micro or t3.micro instances
- **EKS**: Control plane costs $0.10/hour (not free, but minimal)

### Storage
- **S3**: 5 GB standard storage
- **RDS**: 750 hours per month of db.t2.micro, db.t3.micro, or db.t4g.micro

### Networking
- **VPC**: No charge for VPC itself
- **Data Transfer**: 1 GB outbound data transfer per month

### Free Tier Duration
- **12 Months Free**: EC2, S3, RDS
- **Always Free**: VPC, IAM, CloudFormation (within limits)

## Important Notes

### Avoid Unexpected Charges

1. **Set Up Billing Alerts**:
   ```bash
   # Go to Billing Dashboard → Billing preferences
   # Enable "Receive Billing Alerts"
   # Create CloudWatch alarm for billing
   ```

2. **Monitor Usage**:
   - Check AWS Free Tier usage page regularly
   - Set budget alerts

3. **Clean Up Resources**:
   ```bash
   # Always destroy infrastructure when done testing
   terraform destroy
   ```

### Free Tier Limits to Watch

- **EKS**: Not included in free tier ($0.10/hour per cluster)
- **Elastic IPs**: Free when attached to running instance
- **NAT Gateway**: Not free ($0.045/hour)
- **Load Balancers**: Not free

### Cost-Saving Tips

1. **Use t2.micro/t3.micro instances** (free tier eligible)
2. **Stop instances** when not in use (you still pay for EBS storage)
3. **Use single AZ** for development (multi-AZ costs more)
4. **Delete unused snapshots** and AMIs
5. **Clean up S3 buckets** regularly

## Regional Considerations

### Recommended Regions for Free Tier
- **us-east-1** (N. Virginia) - Most services available
- **us-west-2** (Oregon) - Good alternative
- **eu-west-1** (Ireland) - For EU-based projects

## Troubleshooting

### Issue: Account Verification Pending
- **Solution**: Wait 24 hours for AWS to verify your account

### Issue: Credit Card Declined
- **Solution**: Contact your bank to allow international transactions

### Issue: Access Denied Errors
- **Solution**: Check IAM user permissions and attach necessary policies

### Issue: Region Not Supported
- **Solution**: Switch to us-east-1 or check service availability

## Security Best Practices

1. **Never use root account** for day-to-day operations
2. **Enable MFA** on all accounts
3. **Use IAM roles** instead of access keys when possible
4. **Rotate access keys** regularly
5. **Enable CloudTrail** for audit logging
6. **Use Security Groups** properly (least privilege)
7. **Enable AWS Config** for compliance monitoring

## Next Steps

Once your AWS account is configured:

1. Review the Terraform code in `terraform/aws/`
2. Update variables in `terraform.tfvars`
3. Run `terraform init && terraform plan`
4. Review the plan before applying
5. Run `terraform apply`

## Additional Resources

- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Pricing Calculator](https://calculator.aws/)

## Support

For issues with AWS setup:
- AWS Support (Basic tier included)
- AWS Forums
- AWS re:Post community
