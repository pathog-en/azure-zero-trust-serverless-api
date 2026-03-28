## Azure Zero Trust Serverless API

A Terraform-driven Azure architecture demonstrating a Zero Trust serverless API built with Azure Functions (Python), Private Endpoints, Managed Identity, and Key Vault.

This project shows how to build a secure, production-style cloud architecture where services communicate only over private networks, secrets are retrieved using managed identities, and infrastructure is fully defined using Infrastructure as Code.

## Architecture Overview
Client
   |
   v
Azure Function App (Python)
Private Endpoint (Inbound)
   |
   v
VNet Integration Subnet
   |
   +-----------------------> Azure Key Vault (Private Endpoint)
   |
   +-----------------------> Azure Storage Account (Private Endpoint)
   |
   v
Log Analytics + Application Insights
Security Model

## This architecture follows Zero Trust principles:

No public service endpoints
Private endpoint communication
Managed identity authentication
Secrets stored in Key Vault
Infrastructure deployed through Terraform
Centralized logging and monitoring
Key Features
Serverless API
Azure Functions (Python 3.11)
HTTP triggered endpoints
Built using the Python v2 programming model

## Endpoints:

GET /api/health
GET /api/secret-check
Managed Identity Authentication

The Function App retrieves secrets from Key Vault using:

DefaultAzureCredential

No credentials or secrets are stored in code.

Private Networking

All services communicate through Private Endpoints:

Service	Private Endpoint
Function App	inbound
Key Vault	private access
Storage Account	private access

Public network access is disabled wherever possible.

## Observability

The system includes:

Application Insights
Log Analytics Workspace
structured logging from the Function App
Repository Structure
azure-zero-trust-serverless-api
│
├── app
│   ├── function_app.py
│   ├── host.json
│   └── requirements.txt
│
├── infra
│   └── stacks
│       ├── 00-bootstrap
│       ├── 10-core
│       ├── 20-private-services
│       └── 30-workload
│
└── README.md

## Terraform Stacks

Stack	Purpose
00-bootstrap	Terraform state backend
10-core	networking, DNS, monitoring
20-private-services	Key Vault, Storage, Private Endpoints
30-workload	Function App + Managed Identity
Function Endpoints
Health Endpoint
GET /api/health

Returns service health status.

Example response:

{
  "status": "ok",
  "service": "azure-zero-trust-serverless-api",
  "environment": "Production",
  "timestamp_utc": "2026-03-28T17:45:00Z"
}
Secret Check Endpoint
GET /api/secret-check

Demonstrates secure Key Vault access via managed identity.

Example response:

{
  "status": "ok",
  "key_vault_access": "success",
  "secret_name": "demo-config",
  "retrieved": true
}
## Deployment

Infrastructure is deployed using Terraform.

Example deployment flow:

terraform init
terraform plan
terraform apply

Stacks should be deployed in order:

00-bootstrap
10-core
20-private-services
30-workload
Application Deployment

## The Function App uses Azure remote build (Oryx) to install dependencies.

Required configuration:

SCM_DO_BUILD_DURING_DEPLOYMENT=true
ENABLE_ORYX_BUILD=true
FUNCTIONS_WORKER_RUNTIME=python

Deployment command:

az functionapp deployment source config-zip \
  --resource-group <resource-group> \
  --name <function-app-name> \
  --src functionapp-source.zip \
  --build-remote true
Requirements

## Python dependencies:

azure-functions
azure-identity
azure-keyvault-secrets
Security Highlights

## This project demonstrates several enterprise cloud security patterns:

Zero Trust networking
Managed Identity authentication
Private endpoints
Secret management via Key Vault
Infrastructure as Code
Centralized logging
Future Improvements

## Potential extensions to the architecture:

API Management gateway
mTLS authentication
private DNS automation
CI/CD pipeline
automated security scanning
OpenAPI documentation
Learning Objectives

## This project demonstrates practical implementation of:

Azure networking
Terraform infrastructure design
secure serverless architectures
identity-based authentication
production-ready cloud monitoring
License

MIT License.

![alt text](image-1.png)

