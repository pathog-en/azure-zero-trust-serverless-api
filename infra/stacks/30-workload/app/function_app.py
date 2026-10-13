import os
import json
import logging
from datetime import datetime, timezone

import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)


@app.route(route="health", methods=["GET"])
def health(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Processing /api/health request")

    response = {
        "status": "ok",
        "service": "azure-zero-trust-serverless-api",
        "environment": os.getenv("AZURE_FUNCTIONS_ENVIRONMENT", "unknown"),
        "timestamp_utc": datetime.now(timezone.utc).isoformat()
    }

    return func.HttpResponse(
        json.dumps(response, indent=2),
        status_code=200,
        mimetype="application/json"
    )


@app.route(route="secret-check", methods=["GET"])
def secret_check(req: func.HttpRequest) -> func.HttpResponse:
    logging.info("Processing /api/secret-check request")

    key_vault_uri = os.getenv("KEY_VAULT_URI")
    secret_name = os.getenv("SECRET_NAME", "demo-config")

    if not key_vault_uri:
        logging.error("Missing KEY_VAULT_URI application setting")
        return func.HttpResponse(
            json.dumps({
                "status": "error",
                "message": "KEY_VAULT_URI app setting is not configured"
            }, indent=2),
            status_code=500,
            mimetype="application/json"
        )

    
    try:
        credential = DefaultAzureCredential()
        client = SecretClient(vault_url=key_vault_uri, credential=credential)

        secret = client.get_secret(secret_name)

        response = {
            "status": "ok",
            "key_vault_access": "success",
            "secret_name": secret.name,
            "secret_version": secret.properties.version,
            "retrieved": True,
            "message": "Managed identity successfully retrieved the secret."
        }

        return func.HttpResponse(
            json.dumps(response, indent=2),
            status_code=200,
            mimetype="application/json"
        )

    except Exception:
        logging.exception("Failed to retrieve secret from Key Vault")

        response = {
            "status": "error",
            "key_vault_access": "failed",
            "retrieved": False,
            "message": "Unable to retrieve the requested configuration."
        }   


        return func.HttpResponse(
            json.dumps(response, indent=2),
            status_code=500,
            mimetype="application/json"
        )