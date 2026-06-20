"""FastAPI demo app used for progressive delivery experiments."""

import asyncio

from fastapi import FastAPI, HTTPException

from app.database import check_database_connection
from app.metrics import PrometheusMetricsMiddleware, metrics_response
from app.settings import get_settings

app = FastAPI(
    title="Progressive Delivery FastAPI",
    description="A release-safety demo for Kubernetes, Argo Rollouts, and Prometheus.",
    version="1.0.0",
)
app.add_middleware(PrometheusMetricsMiddleware)


@app.get("/")
async def root() -> dict[str, str]:
    settings = get_settings()
    return {
        "service": "progressive-delivery-fastapi",
        "app_version": settings.app_version,
        "release_mode": settings.release_mode,
        "message": "Use /api/message to see the active release behavior.",
    }


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/ready")
async def ready() -> dict[str, str | bool]:
    settings = get_settings()
    return {
        "status": "ready",
        "database_configured": bool(settings.database_url),
    }


@app.get("/version")
async def version() -> dict[str, str]:
    settings = get_settings()
    return {
        "app_version": settings.app_version,
        "release_mode": settings.release_mode,
    }


@app.get("/api/message")
async def message() -> dict[str, str]:
    settings = get_settings()

    if settings.release_mode == "bad-error":
        raise HTTPException(
            status_code=500,
            detail="Intentional bad release: simulated server error.",
        )

    if settings.release_mode == "bad-latency":
        await asyncio.sleep(0.8)

    if settings.app_version == "v2":
        message_text = "Hello from v2. This is the safer, improved release."
    else:
        message_text = "Hello from v1. This is the stable baseline release."

    return {
        "app_version": settings.app_version,
        "release_mode": settings.release_mode,
        "message": message_text,
    }


@app.get("/api/db-check")
async def db_check() -> dict[str, str | bool]:
    settings = get_settings()
    result = check_database_connection(settings.database_url)
    return {
        "database_configured": result.configured,
        "ok": result.ok,
        "message": result.message,
    }


@app.get("/metrics")
async def metrics():
    return metrics_response()
