# Cloud Resume Challenge

![Cloud Resume Challenge](../assets/images/project_icons/100DOC-icon.webp)

**Multi-cloud resume website deployed across AWS, Azure, and Google Cloud Platform. Features visitor counters, AI-powered Q&A, and semantic search - all managed with Terraform and CI/CD pipelines.**

<div class="section-label">Project Status</div>

**Status**: In Progress | **Clouds**: AWS, Azure, GCP | **Goal**: Captain-grade (highest tier)

---

## Project Overview

Building a multi-cloud resume website for the Cloud Resume Challenge Bootcamp. The goal is to achieve Captain-grade (highest tier) by deploying to AWS, Azure, and GCP with AI features on AWS. The project demonstrates cloud architecture, infrastructure as code, serverless computing, and AI integration.

<div class="section-label">Timeline</div>

- **Week 1**: Frontend (static site + CDN + DNS)
- **Week 2**: Backend (APIs + AI features)
- **Budget**: $2-4/month maximum

---

## Architecture

### Multi-Cloud Strategy

**Content**: Shared MkDocs source in `docs/` folder

**Deployment**: Independent per cloud

- **AWS**: Full features (AI included)
- **Azure**: Basic (visitor counter only)
- **GCP**: Basic (visitor counter only)

**CI/CD**: Separate GitHub Actions workflows per cloud

### AWS Architecture (Full Features)

```text
User
  → Route 53 (DNS)
  → CloudFront (CDN)
  → S3 (Static Site)
  → API Gateway
  → Lambda Functions
  → DynamoDB (Visitor Counter)
  → Bedrock/Modal Labs (AI Features)
```

### Azure Architecture (Basic)

```text
User
  → Azure DNS
  → Front Door (CDN)
  → Blob Storage (Static Site)
  → Azure Functions
  → Cosmos DB (Visitor Counter)
```

### GCP Architecture (Basic)

```text
User
  → Cloud DNS
  → Cloud CDN
  → Cloud Storage (Static Site)
  → Cloud Functions
  → Firestore (Visitor Counter)
```

---

## Key Features

### Frontend

- **MkDocs Material Theme**: Clean, professional design
- **Responsive Layout**: Works on all devices
- **Custom CSS**: Portfolio-style aesthetics
- **Project Showcase**: Interactive project cards
- **Resume Content**: Comprehensive professional history

### Backend - Visitor Counter

- **Atomic Increment**: NoSQL database operations
- **CORS Support**: Cross-origin requests
- **Rate Limiting**: 100 requests/IP/minute
- **Multi-Cloud**: Separate implementations per cloud

### AI Features (AWS Only)

#### AI Q&A System

- **RAG Pipeline**: Retrieval-augmented generation
- **Resume Context**: Answers questions about experience
- **Rate Limiting**: 5 requests/IP/minute
- **Daily Quota**: 100 total requests
- **API Key Authentication**: Secure access

#### Semantic Search

- **Pre-computed Embeddings**: Build-time generation
- **Cosine Similarity**: Fast search results
- **Top 5 Results**: Ranked by relevance
- **Rate Limiting**: 10 requests/IP/minute

#### AI Summarizer

- **Build-Time Only**: Not per-request
- **Project Summaries**: 2-3 sentence descriptions
- **Automatic Injection**: Into project pages

---

## Technology Stack

### Infrastructure as Code

- **Terraform**: All cloud resources
- **Remote State**: S3 with DynamoDB locking
- **Modules**: Reusable components
- **Variables**: Configurable values

### Frontend

- **MkDocs**: Static site generator
- **Material Theme**: Professional design
- **Custom CSS/JS**: Enhanced functionality
- **Markdown**: Content management

### Backend

- **AWS**: Lambda, API Gateway, DynamoDB
- **Azure**: Azure Functions, Cosmos DB
- **GCP**: Cloud Functions, Firestore
- **Python**: Lambda/Function code

### AI Services

- **Modal Labs**: Free credits (primary)
- **Nebius AI**: Free credits (backup)
- **AWS Bedrock**: Last resort
- **Embeddings**: Pre-computed at build time

### CI/CD

- **GitHub Actions**: Automated deployments
- **Terraform Plan/Apply**: Infrastructure updates
- **MkDocs Build**: Site generation
- **CloudFront Invalidation**: Cache clearing

---

## Security & Cost Optimization

### Security

**Rate Limiting:**

- AI Q&A: 5 requests/IP/minute
- AI Search: 10 requests/IP/minute
- Visitor Counter: 100 requests/IP/minute

**Quotas:**

- Daily AI request limit: 100 total
- CloudWatch alarms on unusual usage

**Authentication:**

- API keys for AI endpoints (Secrets Manager)
- Request size limits (500 chars for questions)
- Input validation and sanitization

### Cost Optimization

**Budget**: $2-4/month maximum

**AI Services:**

- Use Modal Labs free credits first
- Use Nebius AI free credits as backup
- AWS Bedrock only as last resort
- AI Search uses pre-computed embeddings (free)
- AI Summarizer runs at build-time only

**Free Tier Usage:**

- AWS: S3, CloudFront (12 months), Lambda, DynamoDB
- Azure: Blob Storage, Functions, Cosmos DB
- GCP: Cloud Storage, Cloud Functions, Firestore

---

## Skills Demonstrated

**Cloud Architecture**: Multi-cloud deployment, CDN configuration, DNS management, serverless computing

**Infrastructure as Code**: Terraform modules, state management, resource tagging, best practices

**Serverless Development**: Lambda functions, API Gateway, Azure Functions, Cloud Functions

**AI/ML Integration**: RAG pipelines, embeddings, semantic search, LLM integration

**DevOps**: CI/CD pipelines, GitHub Actions, automated deployments, monitoring

**Security**: Rate limiting, API authentication, input validation, secrets management

**Cost Optimization**: Free tier usage, resource tagging, budget monitoring, efficient architecture

**Frontend Development**: MkDocs, Material theme, custom CSS/JS, responsive design

---

## Deployment Checklist

Before deploying to production:

- Run `terraform plan` and review changes
- Check cost estimate (should be < $5/month)
- Verify rate limiting is configured
- Test visitor counter works
- Test AI features (if AWS)
- Verify HTTPS works
- Check DNS resolution
- Run smoke tests
- Set up CloudWatch alarms

---

## Links

- **GitHub**: [cloud-resume-challenge](https://github.com/Ramsi-K/cloud-resume-challenge)
- **Live Site**: [ramsi.dev](https://ramsi.dev)
- **100 Days of Cloud**: [Journey Log](https://github.com/Ramsi-K/100DaysOfCloud)
- **Cloud Resume Challenge**: [Official Site](https://cloudresumechallenge.dev)

---

[← Back to Projects](index.md)
