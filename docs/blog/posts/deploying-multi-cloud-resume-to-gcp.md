---
date: 2025-12-30
categories:
  - cloud-infrastructure
  - gcp
  - terraform
  - devops
tags:
  - google-cloud
  - cloud-functions
  - firestore
  - cloud-storage
  - cloud-cdn
  - terraform
  - infrastructure-as-code
---

# Deploying Multi-Cloud Resume to GCP: Frontend and Backend

This post details the deployment of our multi-cloud resume to GCP. The frontend is deployed to Cloud Storage and Cloud CDN, while the backend is deployed to Cloud Functions and Firestore.

<!-- more -->

After successfully deploying to AWS, the next step was Google Cloud Platform. This deployment would demonstrate GCP's serverless capabilities while maintaining cost optimization within our $2-4/month budget, with Azure deployment planned as the final step.

## Architecture Overview

The GCP deployment follows a similar pattern to our other clouds but leverages GCP-specific services:

**Frontend Stack:**

- Cloud Storage for static website hosting
- Cloud CDN via Load Balancer for global distribution
- Managed SSL certificates for HTTPS
- Cloud DNS for custom domain management

**Backend Stack:**

- Cloud Functions (Gen 2) for serverless API
- Firestore for NoSQL database
- Rate limiting and CORS support

## Frontend Deployment Journey

### The Smooth Start

The frontend deployment began promisingly. GCP's Terraform provider (version 6.0) offered excellent resource coverage, and the architecture mapped cleanly to GCP services.

Key components deployed successfully:

- Cloud Storage bucket with website configuration
- Global Load Balancer with backend bucket
- Managed SSL certificate for automatic HTTPS
- Cloud DNS zone with A records

### Challenge: Resource Labeling

Our first hiccup came with GCP's strict labeling requirements. Unlike AWS tags, GCP labels must be lowercase with underscores:

This required updating our common tags variable to comply with GCP conventions.

### SSL Certificate Provisioning

The managed SSL certificate entered a "PROVISIONING" state, which is expected behavior. GCP requires DNS propagation before certificates become active - a process that can take 15-60 minutes.

## Backend Deployment: The Permission Maze

The backend deployment proved more challenging, primarily due to GCP's granular permission model.

### API Enablement Issues

Initially, Terraform attempted to enable required APIs but encountered permission errors:

```
Error 403: Permission denied to enable service [cloudfunctions.googleapis.com]
```

**Solution:** We enabled APIs manually via gcloud CLI and removed the `google_project_service` resources from Terraform to avoid permission conflicts.

### Service Account Permission Chain

The most complex challenge involved service account permissions. Our terraform service account needed multiple roles:

1. `roles/iam.serviceAccountAdmin` - to create function service accounts
2. `roles/datastore.owner` - for Firestore database creation
3. `roles/cloudfunctions.admin` - for function deployment
4. `roles/resourcemanager.projectIamAdmin` - for IAM policy management

### The "ActAs" Permission Challenge

Even with proper roles, we encountered:

```
Error 403: Caller is missing permission 'iam.serviceaccounts.actAs'
```

This required granting `roles/iam.serviceAccountUser` to our terraform service account on both:

- The custom function service account
- The default compute service account

### Cloud Run Public Access

Cloud Functions Gen 2 uses Cloud Run under the hood, but our Terraform IAM binding for public access didn't propagate correctly.

**Solution:** Manual Cloud Run IAM policy binding:

```bash
gcloud run services add-iam-policy-binding [service-name] \
  --member='allUsers' --role='roles/run.invoker'
```

## Testing and Validation

Once deployed, the visitor counter API worked cleanly:

- **GET requests:** Return current count without incrementing
- **POST requests:** Atomically increment and return new count
- **Rate limiting:** 100 requests per IP per minute
- **CORS:** Properly configured for cross-origin requests

The Firestore integration provided atomic transactions, ensuring accurate visitor counts even under concurrent load.

## Cost Analysis

The GCP deployment budget:

- **Cloud Storage:** Free tier (5GB)
- **Cloud Functions:** Free tier (2M invocations/month)
- **Firestore:** Free tier (1GB storage)
- **Cloud DNS:** ~$0.50/month (only billable component)
- **SSL Certificate:** Free (managed)
- **Load Balancer:** Minimal cost for low traffic

**Total estimated cost:** ~$1.00/month

## Lessons Learned

### GCP-Specific Considerations

1. **Permission Model:** GCP's IAM is more granular than AWS, requiring careful role assignment
2. **API Dependencies:** Manual API enablement often smoother than Terraform automation
3. **Cloud Functions Gen 2:** Uses Cloud Run, requiring additional IAM considerations
4. **Resource Naming:** GCP has stricter naming conventions than other clouds

### Multi-Cloud Progress

Deploying the same architecture across AWS and now GCP highlighted interesting differences:

- **AWS:** Most mature Terraform support, clearest documentation
- **GCP:** Most granular permissions, excellent free tiers
- **Azure:** (Planned next phase)

## Architecture Comparison

| Component          | AWS        | GCP             | Azure (Planned) |
| ------------------ | ---------- | --------------- | --------------- |
| **Static Hosting** | S3         | Cloud Storage   | Blob Storage    |
| **CDN**            | CloudFront | Cloud CDN       | Front Door      |
| **Serverless**     | Lambda     | Cloud Functions | Functions       |
| **Database**       | DynamoDB   | Firestore       | Cosmos DB       |
| **DNS**            | Route 53   | Cloud DNS       | DNS Zone        |

## Conclusion

GCP's deployment challenged us with its permission model but rewarded us with excellent free tiers and robust serverless capabilities. The granular IAM system, while complex, provides fine-grained security control that enterprise environments would appreciate.

With AWS and GCP now deployed, the foundation is set for completing the multi-cloud architecture with Azure, demonstrating platform-agnostic design principles across all major cloud providers.

---

**Repository:** [View the complete GCP Terraform configuration](https://github.com/Ramsi-K/cloud-resume-challenge/tree/main/gcp)
