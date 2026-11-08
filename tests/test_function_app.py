
import importlib.util
import json
from pathlib import Path
from unittest.mock import MagicMock

import azure.functions as func


APP_PATH = (
    Path(__file__).resolve().parents[1]
    / "infra"
    / "stacks"
    / "30-workload"
    / "app"
    / "function_app.py"
)


def load_function_module():
    spec = importlib.util.spec_from_file_location(
        "function_app_under_test",
        APP_PATH,
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_health_returns_success(monkeypatch):
    monkeypatch.setenv(
        "AZURE_FUNCTIONS_ENVIRONMENT",
        "Development",
    )

    module = load_function_module()

    request = func.HttpRequest(
        method="GET",
        url="http://localhost:7071/api/health",
        body=b"",
    )

    response = module.health(request)
    payload = json.loads(response.get_body())

    assert response.status_code == 200
    assert payload["status"] == "ok"
    assert payload["service"] == "azure-zero-trust-serverless-api"
    assert payload["environment"] == "Development"
    assert "timestamp_utc" in payload


def make_request():
    return func.HttpRequest(
        method="GET",
        url="http://localhost:7071/api/secret-check",
        body=b"",
    )


def test_secret_check_missing_config(monkeypatch):
    monkeypatch.delenv("KEY_VAULT_URI", raising=False)

    module = load_function_module()
    response = module.secret_check(make_request())
    payload = json.loads(response.get_body())

    assert response.status_code == 500
    assert payload["status"] == "error"
    assert "KEY_VAULT_URI" in payload["message"]


def test_secret_check_success(monkeypatch):
    monkeypatch.setenv(
        "KEY_VAULT_URI",
        "https://kv-example.vault.azure.net/",
    )
    monkeypatch.setenv("SECRET_NAME", "demo-config")

    module = load_function_module()

    fake_credential = MagicMock()
    fake_client = MagicMock()

    fake_secret = MagicMock()
    fake_secret.name = "demo-config"
    fake_secret.properties.version = "test-version"
    fake_client.get_secret.return_value = fake_secret

    monkeypatch.setattr(
        module,
        "DefaultAzureCredential",
        lambda: fake_credential,
    )

    client_factory = MagicMock(return_value=fake_client)
    monkeypatch.setattr(
        module,
        "SecretClient",
        client_factory,
    )

    response = module.secret_check(make_request())
    payload = json.loads(response.get_body())

    assert response.status_code == 200
    assert payload["status"] == "ok"
    assert payload["key_vault_access"] == "success"
    assert payload["retrieved"] is True

    client_factory.assert_called_once_with(
        vault_url="https://kv-example.vault.azure.net/",
        credential=fake_credential,
    )
    fake_client.get_secret.assert_called_once_with(
        "demo-config"
    )


def test_secret_check_failure_hides_details(monkeypatch):
    monkeypatch.setenv(
        "KEY_VAULT_URI",
        "https://kv-example.vault.azure.net/",
    )

    module = load_function_module()

    fake_client = MagicMock()
    fake_client.get_secret.side_effect = Exception(
        "INTERNAL_TEST_SECRET_DO_NOT_EXPOSE"
    )

    monkeypatch.setattr(
        module,
        "DefaultAzureCredential",
        MagicMock(),
    )
    monkeypatch.setattr(
        module,
        "SecretClient",
        MagicMock(return_value=fake_client),
    )

    response = module.secret_check(make_request())
    payload = json.loads(response.get_body())

    assert response.status_code == 500
    assert payload["status"] == "error"
    assert payload["retrieved"] is False
    assert (
        "INTERNAL_TEST_SECRET_DO_NOT_EXPOSE"
        not in response.get_body().decode()
    )
    assert "error" not in payload
