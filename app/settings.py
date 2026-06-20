"""Application settings loaded from environment variables.

The app intentionally uses a tiny settings layer so beginners can see exactly
which values control release behavior during a rollout.
"""

import os
from dataclasses import dataclass

VALID_APP_VERSIONS = {"v1", "v2"}
VALID_RELEASE_MODES = {"good", "bad-error", "bad-latency"}


@dataclass(frozen=True)
class Settings:
    app_version: str = "v1"
    release_mode: str = "good"
    database_url: str | None = None


def _clean(value: str | None, default: str) -> str:
    if value is None:
        return default
    value = value.strip()
    return value or default


def get_settings() -> Settings:
    """Return settings for the current request.

    The function reads environment variables each time instead of caching them.
    That keeps local tests simple and makes release-mode behavior easy to
    demonstrate.
    """

    app_version = _clean(os.getenv("APP_VERSION"), "v1")
    release_mode = _clean(os.getenv("RELEASE_MODE"), "good")

    if app_version not in VALID_APP_VERSIONS:
        app_version = "v1"

    if release_mode not in VALID_RELEASE_MODES:
        release_mode = "good"

    database_url = os.getenv("DATABASE_URL")
    if database_url:
        database_url = database_url.strip() or None

    return Settings(
        app_version=app_version,
        release_mode=release_mode,
        database_url=database_url,
    )
