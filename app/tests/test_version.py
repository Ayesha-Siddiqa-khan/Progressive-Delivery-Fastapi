from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_version_defaults_to_v1_good(monkeypatch):
    monkeypatch.delenv("APP_VERSION", raising=False)
    monkeypatch.delenv("RELEASE_MODE", raising=False)

    response = client.get("/version")

    assert response.status_code == 200
    assert response.json() == {"app_version": "v1", "release_mode": "good"}


def test_message_changes_for_v2(monkeypatch):
    monkeypatch.setenv("APP_VERSION", "v2")
    monkeypatch.setenv("RELEASE_MODE", "good")

    response = client.get("/api/message")

    assert response.status_code == 200
    assert response.json()["app_version"] == "v2"
    assert "improved release" in response.json()["message"]
