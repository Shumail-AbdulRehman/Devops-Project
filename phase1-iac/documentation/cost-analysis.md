# Multi-Cloud Cost Analysis Report
## AWS vs Azure vs GCP Infrastructure Comparison

**Date**: December 2025  
**Scope**: VPC/VNet + Single-Node Kubernetes Cluster + Storage Bucket  
**Region Basis**: US East regions for fair comparison  
**Analysis Period**: Monthly costs

---

## Executive Summary

This report provides a detailed cost comparison of equivalent infrastructure across AWS, Azure, and Google Cloud Platform (GCP). We analyze the costs for deploying:
- Virtual network infrastructure
- Single-node Kubernetes cluster
- Object storage (bucket)

**Key Findings**:
- **AWS** is most cost-effective for managed Kubernetes (EKS)
- **Azure** offers competitive pricing with AKS being free tier friendly
- **GCP** provides the best value for Kubernetes management (GKE Autopilot)
- Storage costs are comparable across all three platforms
- Network costs vary significantly based on usage patterns

---

## 1. Infrastructure Specifications

### 1.1 Common Requirements

To ensure fair comparison, we standardize the infrastructure:

| Component | Specification |
|-----------|---------------|
| **Network** | 1 VPC/VNet with public and private subnets |
| **Kubernetes** | 1 control plane + 1 worker node (2 vCPU, 8GB RAM) |
| **Storage** | 100 GB standard object storage |
| **Region** | US East (AWS: us-east-1, Azure: eastus, GCP: us-east1) |
| **Availability** | Single AZ/Zone (development scenario) |
| **Data Transfer** | 100 GB egress per month |

---

## 2. AWS Cost Breakdown

### 2.1 Network Infrastructure (VPC)

| Resource | Cost | Notes |
|----------|------|-------|
| VPC | **$0.00/month** | No charge for VPC |
| Subnets (2) | **$0.00/month** | No charge for subnets |
| Internet Gateway | **$0.00/month** | No charge for IGW |
| Route Tables (2) | **$0.00/month** | No charge for route tables |
| NAT Gateway | **$32.40/month** | $0.045/hour = $32.40 |
| Elastic IP (NAT) | **$0.00/month** | Free when attached to running resource |

**VPC Total**: **$32.40/month**

> **Cost Optimization**: Use EC2 instance as NAT instance instead of NAT Gateway to save ~$30/month (not recommended for production)

### 2.2 Kubernetes (EKS)

| Resource | Cost | Notes |
|----------|------|-------|
| EKS Control Plane | **$73.00/month** | $0.10/hour = $73.00 |
| Worker Node (t3.medium) | **$30.37/month** | $0.0416/hour = $30.37 |
| EBS Storage (50 GB gp3) | **$4.00/month** | $0.08/GB-month |
| Data Transfer (egress) | **$9.00/month** | $0.09/GB for 100 GB |

**EKS Total**: **$116.37/month**

### 2.3 Storage (S3)

| Resource | Cost | Notes |
|----------|------|-------|
| S3 Standard Storage (100 GB) | **$2.30/month** | $0.023/GB-month |
| PUT Requests (10,000) | **$0.05/month** | $0.005 per 1,000 requests |
| GET Requests (100,000) | **$0.04/month** | $0.0004 per 1,000 requests |

**S3 Total**: **$2.39/month**

### 2.4 AWS Total Monthly Cost

| Category | Cost |
|----------|------|
| Network (VPC + NAT) | $32.40 |
| Kubernetes (EKS) | $116.37 |
| Storage (S3) | $2.39 |
| **TOTAL** | **$151.16/month** |
| **Annual Cost** | **$1,813.92/year** |

---

## 3. Azure Cost Breakdown

### 3.1 Network Infrastructure (VNet)

| Resource | Cost | Notes |
|----------|------|-------|
| Virtual Network | **$0.00/month** | No charge for VNet |
| Subnets (2) | **$0.00/month** | No charge for subnets |
| Public IP (Standard) | **$3.65/month** | $0.005/hour = $3.65 |
| NAT Gateway | **$32.85/month** | $0.045/hour = $32.85 |
| NAT Gateway Data | **$4.50/month** | $0.045/GB for 100 GB processed |

**VNet Total**: **$41.00/month**

### 3.2 Kubernetes (AKS)

| Resource | Cost | Notes |
|----------|------|-------|
| AKS Control Plane | **$0.00/month** | FREE (major advantage!) |
| Worker Node (Standard_B2s) | **$30.37/month** | $0.0416/hour (2 vCPU, 4 GB) |
| Managed Disk (128 GB Standard SSD) | **$9.73/month** | $0.076/GB-month |
| Data Transfer (egress) | **$8.70/month** | $0.087/GB for 100 GB |

**AKS Total**: **$48.80/month**

> **Note**: For 8GB RAM, use Standard_B2ms ($60.74/month) instead of B2s

### 3.3 Storage (Blob Storage)

| Resource | Cost | Notes |
|----------|------|-------|
| Blob Storage (100 GB, Hot tier) | **$1.84/month** | $0.0184/GB-month |
| Write Operations (10,000) | **$0.05/month** | $0.05 per 10,000 |
| Read Operations (100,000) | **$0.04/month** | $0.004 per 10,000 |

**Blob Storage Total**: **$1.93/month**

### 3.4 Azure Total Monthly Cost

| Category | Cost |
|----------|------|
| Network (VNet + NAT) | $41.00 |
| Kubernetes (AKS) | $48.80 |
| Storage (Blob) | $1.93 |
| **TOTAL** | **$91.73/month** |
| **Annual Cost** | **$1,100.76/year** |

**With 8GB RAM node (B2ms)**:
- **Total**: **$122.11/month** or **$1,465.32/year**

---

## 4. GCP Cost Breakdown

### 4.1 Network Infrastructure (VPC)

| Resource | Cost | Notes |
|----------|------|-------|
| VPC Network | **$0.00/month** | No charge for VPC |
| Subnets (2) | **$0.00/month** | No charge for subnets |
| External IP Address | **$7.30/month** | $0.010/hour = $7.30 |
| Cloud NAT Gateway | **$32.85/month** | $0.045/hour = $32.85 |
| Cloud NAT Data Processing | **$4.50/month** | $0.045/GB for 100 GB |

**VPC Total**: **$44.65/month**

### 4.2 Kubernetes (GKE)

**Option 1: GKE Standard**

| Resource | Cost | Notes |
|----------|------|-------|
| GKE Control Plane | **$73.00/month** | $0.10/hour = $73.00 |
| Worker Node (e2-standard-2) | **$48.54/month** | $0.067/hour (2 vCPU, 8 GB) |
| Persistent Disk (100 GB Standard) | **$4.00/month** | $0.04/GB-month |
| Data Transfer (egress) | **$12.00/month** | $0.12/GB for 100 GB |

**GKE Standard Total**: **$137.54/month**

**Option 2: GKE Autopilot** (Recommended)

| Resource | Cost | Notes |
|----------|------|-------|
| GKE Autopilot (managed) | **$0.00/month** | No cluster management fee |
| Compute (2 vCPU, 8 GB) | **$52.50/month** | Pay-per-pod pricing |
| Storage (100 GB) | **$17.00/month** | Included in pod pricing |
| Data Transfer (egress) | **$12.00/month** | $0.12/GB for 100 GB |

**GKE Autopilot Total**: **$81.50/month**

### 4.3 Storage (Cloud Storage)

| Resource | Cost | Notes |
|----------|------|-------|
| Cloud Storage Standard (100 GB) | **$2.00/month** | $0.020/GB-month |
| Class A Operations (10,000) | **$0.05/month** | $0.05 per 10,000 |
| Class B Operations (100,000) | **$0.04/month** | $0.004 per 10,000 |

**Cloud Storage Total**: **$2.09/month**

### 4.4 GCP Total Monthly Cost

**With GKE Standard**:

| Category | Cost |
|----------|------|
| Network (VPC + NAT) | $44.65 |
| Kubernetes (GKE Standard) | $137.54 |
| Storage (Cloud Storage) | $2.09 |
| **TOTAL** | **$184.28/month** |
| **Annual Cost** | **$2,211.36/year** |

**With GKE Autopilot** (Recommended):

| Category | Cost |
|----------|------|
| Network (VPC + NAT) | $44.65 |
| Kubernetes (GKE Autopilot) | $81.50 |
| Storage (Cloud Storage) | $2.09 |
| **TOTAL** | **$128.24/month** |
| **Annual Cost** | **$1,538.88/year** |

---

## 5. Side-by-Side Comparison

### 5.1 Monthly Cost Comparison

| Component | AWS | Azure | GCP (Standard) | GCP (Autopilot) |
|-----------|-----|-------|----------------|-----------------|
| **Network** | $32.40 | $41.00 | $44.65 | $44.65 |
| **Kubernetes** | $116.37 | $48.80* | $137.54 | $81.50 |
| **Storage** | $2.39 | $1.93 | $2.09 | $2.09 |
| **TOTAL** | **$151.16** | **$91.73** | **$184.28** | **$128.24** |

*With 4GB RAM node; $122.11 with 8GB RAM node

### 5.2 Annual Cost Comparison

| Provider | Configuration | Annual Cost | Savings vs AWS |
|----------|---------------|-------------|----------------|
| Azure | AKS (4GB node) | **$1,100.76** | **39.3%** |
| Azure | AKS (8GB node) | **$1,465.32** | **19.2%** |
| GCP | GKE Autopilot | **$1,538.88** | **15.2%** |
| AWS | EKS | **$1,813.92** | Baseline |
| GCP | GKE Standard | **$2,211.36** | -21.9% |

### 5.3 Visual Cost Breakdown

```
Monthly Cost Comparison (Bar Chart Representation)

AWS:     ████████████████████ $151.16
Azure*:  ████████████████ $122.11
GCP-AP:  ███████████████████ $128.24
GCP-Std: ███████████████████████ $184.28

Legend:
* Azure with 8GB node
AP = Autopilot
Std = Standard
```

---

## 6. Free Tier Considerations

### 6.1 AWS Free Tier (12 Months)

| Service | Free Tier Allowance | Impact on This Project |
|---------|---------------------|------------------------|
| EC2 | 750 hours/month t2.micro | ⚠️ Need t3.medium for K8s |
| S3 | 5 GB storage | ✅ Covers storage needs |
| Data Transfer | 1 GB egress | ⚠️ Need 100 GB |
| EKS | Not included | ❌ Full cost applies |

**Free Tier Savings**: **~$2.39/month** (S3 only)

### 6.2 Azure Free Tier (12 Months)

| Service | Free Tier Allowance | Impact on This Project |
|---------|---------------------|------------------------|
| VMs | 750 hours/month B1s | ⚠️ Need B2s/B2ms for K8s |
| Blob Storage | 5 GB LRS | ✅ Covers storage needs |
| Data Transfer | 15 GB egress | ⚠️ Need 100 GB |
| AKS | Free control plane | ✅ Always free! |

**Free Tier Savings**: **$1.93/month** (Blob) + **$0.00** (AKS always free)

**Major Advantage**: AKS control plane is ALWAYS free, not just in free tier.

### 6.3 GCP Free Tier

**Trial**: $300 credit for 90 days (covers entire project for ~2 months)

**Always Free Tier**:

| Service | Free Tier Allowance | Impact on This Project |
|---------|---------------------|------------------------|
| Compute | 1 e2-micro VM | ❌ Need e2-standard-2 |
| Cloud Storage | 5 GB | ✅ Covers storage needs |
| Data Transfer | 1 GB egress | ⚠️ Need 100 GB |
| GKE | Not in always-free | ❌ Full cost applies |

**Free Tier Savings**: **$300 credit** (first 90 days) + **$2.09/month** (storage)

---

## 7. Cost Optimization Strategies

### 7.1 Network Costs

**Challenge**: NAT Gateway is expensive across all clouds (~$33-45/month)

**Optimization Options**:

1. **Use NAT Instance** (AWS/Azure/GCP):
   - Cost: ~$10-15/month (small VM)
   - Savings: ~$20/month
   - Trade-off: Management overhead, lower throughput

2. **Eliminate NAT** (if possible):
   - Use public IPs on worker nodes
   - Savings: $33-45/month
   - Trade-off: Security concerns

3. **Use Cloud Provider VPN**:
   - For private connectivity
   - More expensive initially, better for scale

### 7.2 Kubernetes Costs

**AWS EKS**:
- ❌ Cannot avoid $73/month control plane fee
- ✅ Use Spot instances for worker nodes (70% savings)
- ✅ Use Fargate for serverless (pay per pod)

**Azure AKS**:
- ✅ Control plane already free!
- ✅ Use B-series burstable VMs (already optimized)
- ✅ Enable cluster autoscaler (scale to zero when idle)

**GCP GKE**:
- ✅ Use Autopilot mode (no control plane fee + optimization)
- ✅ Use Spot/Preemptible VMs (up to 80% savings)
- ✅ Enable node auto-provisioning

### 7.3 Storage Costs

Storage is relatively cheap across all platforms ($2-3/month for 100 GB).

**Optimization**:
- Use lifecycle policies to move old data to cheaper tiers
- Enable compression
- Clean up unused data

**Storage Tier Comparison** (per GB/month):

| Tier | AWS S3 | Azure Blob | GCP Cloud Storage |
|------|--------|------------|-------------------|
| Hot/Standard | $0.023 | $0.0184 | $0.020 |
| Cool/Infrequent | $0.0125 | $0.010 | $0.010 |
| Archive | $0.004 | $0.002 | $0.0012 |

### 7.4 Data Transfer Costs

**Challenge**: Data transfer (egress) is expensive

| Provider | Cost per GB (after free tier) |
|----------|-------------------------------|
| AWS | $0.09/GB |
| Azure | $0.087/GB |
| GCP | $0.12/GB |

**Optimization**:
- Use CDN for static content
- Enable compression
- Minimize cross-region traffic
- Use Direct Connect/ExpressRoute/Interconnect for high volume

---

## 8. Spot/Preemptible Instance Savings

### 8.1 AWS Spot Instances

- **Discount**: Up to 90% off on-demand pricing
- **t3.medium Spot**: ~$9/month (vs $30.37 on-demand)
- **Savings on Worker Node**: ~$21/month
- **Trade-off**: Can be interrupted with 2-minute notice

**AWS with Spot**: **~$130/month** (vs $151.16)

### 8.2 Azure Spot VMs

- **Discount**: Up to 90% off on-demand pricing
- **B2ms Spot**: ~$18/month (vs $60.74 on-demand)
- **Savings on Worker Node**: ~$42/month
- **Trade-off**: Can be evicted

**Azure with Spot**: **~$80/month** (vs $122.11)

### 8.3 GCP Preemptible VMs

- **Discount**: Up to 80% off on-demand pricing
- **e2-standard-2 Preemptible**: ~$14/month (vs $48.54)
- **Benefit**: Predictable pricing
- **Trade-off**: Max 24-hour runtime

**GCP Standard with Preemptible**: **~$150/month** (vs $184.28)  
**GCP Autopilot**: Automatically uses Spot when available

---

## 9. Reserved/Committed Use Discounts

For long-term deployments (1-3 years):

### 9.1 AWS Reserved Instances

- **1-Year**: 30-40% discount
- **3-Year**: 50-60% discount
- **EKS with 1-Year RI**: ~$108/month (vs $151.16)

### 9.2 Azure Reserved Instances

- **1-Year**: 30-40% discount
- **3-Year**: 60-70% discount
- **AKS with 1-Year RI**: ~$85/month (vs $122.11)

### 9.3 GCP Committed Use Discounts

- **1-Year**: 25-37% discount
- **3-Year**: 52-55% discount
- **GKE Autopilot with 1-Year CUD**: ~$95/month (vs $128.24)

---

## 10. Cost Scenarios Summary

### 10.1 Development/Testing (Can tolerate interruptions)

| Provider | Configuration | Monthly Cost |
|----------|---------------|--------------|
| **Azure** | AKS + B2ms Spot VM | **~$80** |
| **GCP** | GKE Autopilot + Spot | **~$95** |
| **AWS** | EKS + t3.medium Spot | **~$130** |

**Winner**: **Azure** - Free control plane + cheap Spot VMs

### 10.2 Production (On-Demand, High Availability)

| Provider | Configuration | Monthly Cost |
|----------|---------------|--------------|
| **Azure** | AKS + B2ms On-Demand | **~$122** |
| **GCP** | GKE Autopilot On-Demand | **~$128** |
| **AWS** | EKS + t3.medium On-Demand | **~$151** |

**Winner**: **Azure** - Free control plane makes the difference

### 10.3 Production (1-Year Reserved/Committed)

| Provider | Configuration | Monthly Cost |
|----------|---------------|--------------|
| **Azure** | AKS + 1-Year RI | **~$85** |
| **GCP** | GKE Autopilot + 1-Year CUD | **~$95** |
| **AWS** | EKS + 1-Year RI | **~$108** |

**Winner**: **Azure** - Consistently most cost-effective

###10.4 Multi-Cloud Strategy Cost

Running on **all three clouds** simultaneously:

- **Development**: ~$305/month (~$3,660/year)
- **Production**: ~$401/month (~$4,812/year)
- **Production with committed discounts**: ~$288/month (~$3,456/year)

---

## 11. Hidden Costs to Consider

### 11.1 Data Transfer Costs

Often the biggest surprise:

- **Within Region**: Usually free
- **Between Regions**: $0.01-0.02/GB
- **To Internet**: $0.08-0.12/GB
- **Between Clouds**: Full egress charges

**Example**: 500 GB egress/month = $40-60/month additional

### 11.2 Additional Services

| Service | AWS | Azure | GCP |
|---------|-----|-------|-----|
| Load Balancer | ~$16/month | ~$18/month | ~$18/month |
| Autoscaling | Free | Free | Free |
| Monitoring | Free tier, then paid | Free tier, then paid | Free tier, then paid |
| DNS | $0.50/zone + queries | $0.50/zone + queries | $0.20/zone + queries |

### 11.3 Support Plans

| Level | AWS | Azure | GCP |
|-------|-----|-------|-----|
| Basic/Free | Free | Free | Free |
| Developer | $29/month | $29/month | $29/month |
| Business | $100/month | $100/month | $150/month |
| Enterprise | $15,000/month | $15,000/month | $15,000/month |

---

## 12. Recommendations

### 12.1 Cost Winner by Scenario

**Pure Cost Optimization (Development)**:
🥇 **Azure** - $80/month with Spot VMs  
🥈 **GCP Autopilot** - $95/month with Spot  
🥉 **AWS** - $130/month with Spot

**Production (Reliability + Cost)**:
🥇 **Azure** - $122/month with free control plane  
🥈 **GCP Autopilot** - $128/month with managed ops  
🥉 **AWS** - $151/month

**Long-Term Commitment (1-Year)**:
🥇 **Azure** - $85/month  
🥈 **GCP Autopilot** - $95/month  
🥉 **AWS** - $108/month

### 12.2 Decision Matrix

Choose **AWS** if:
- Already invested in AWS ecosystem
- Need specific AWS services
- Prioritize AWS support and documentation
- Cost is not the primary concern

Choose **Azure** if:
- **Cost optimization is priority** ✅
- Microsoft ecosystem alignment
- Free AKS control plane is attractive
- Good balance of cost and features

Choose **GCP** if:
- Want advanced Kubernetes features (GKE Autopilot)
- Prefer Google's managed services approach
- Need GCP-specific services (BigQuery, etc.)
- Have $300 free trial to get started

### 12.3 Multi-Cloud Consideration

**Total Cost**: ~$288-401/month

**Benefits**:
- Vendor independence
- High availability across providers
- Best-of-breed services per cloud
- Risk mitigation

**Drawbacks**:
- Operational complexity
- Multiple billing systems
- Increased management overhead

---

## 13. Conclusion

### 13.1 Key Takeaways

1. **Azure wins on cost** for Kubernetes workloads due to free AKS control plane
2. **AWS has the most predictable pricing** but higher baseline costs
3. **GCP Autopilot offers best value** for managed Kubernetes when comparing feature-to-cost ratio
4. **Network costs (NAT Gateway) are similar** across all platforms (~$33-45/month)
5. **Storage costs are negligible** compared to compute (~$2-3/month for 100GB)
6. **Spot/Preemptible instances** can reduce costs by 70-90%
7. **Long-term commitments** provide 30-60% discounts

### 13.2 Final Cost Summary

| Scenario | AWS | Azure | GCP (Autopilot) | Cost Leader |
|----------|-----|-------|-----------------|-------------|
| Development (Spot) | $130 | $80 | $95 | **Azure** |
| Production (On-Demand) | $151 | $122 | $128 | **Azure** |
| Production (1-Yr Committed) | $108 | $85 | $95 | **Azure** |
| Free Trial Impact | Minimal | Good | Excellent | **GCP** |

### 13.3 Strategic Recommendation

**For this specific project** (VPC + 1-node K8s + Storage):

**Best Choice**: **Azure AKS** offers the best combination of cost-effectiveness and features, saving approximately **$350-713/year** compared to AWS.

**Alternative**: **GCP GKE Autopilot** for those preferring Google's managed approach, especially with the $300 trial credit.

**Consider AWS if**: Already standardized on AWS or need AWS-specific integrations.

---

## Appendix: Cost Calculation Methodology

### Assumptions:
- Pricing as of December 2025
- US East regions only
- Single AZ for development
- 730 hours/month (24*365/12)
- No discounts unless specified
- Standard support tier (free)

### Pricing Sources:
- AWS Pricing Calculator
- Azure Pricing Calculator
- GCP Pricing Calculator
- Official vendor pricing pages

### Notes:
- Prices may vary by region
- Prices subject to change
- Additional costs may apply for specific features
- Free tiers and trials have expiration dates
- Your actual costs may vary based on usage patterns

---

**Document Version**: 1.0  
**Last Updated**: December 2025  
**Next Review**: March 2026
