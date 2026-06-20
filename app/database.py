"""Small PostgreSQL connectivity helper.

The application must not fail to start when DATABASE_URL is missing. This helper
only attempts a connection when the /api/db-check endpoint is called.
"""

from dataclasses import dataclass

import psycopg


@dataclass(frozen=True)
class DatabaseCheckResult:
    configured: bool
    ok: bool
    message: str


def check_database_connection(database_url: str | None) -> DatabaseCheckResult:
    if not database_url:
        return DatabaseCheckResult(
            configured=False,
            ok=True,
            message="DATABASE_URL is not configured. The app is running without a database.",
        )

    try:
        with psycopg.connect(database_url, connect_timeout=3) as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()
    except Exception as exc:  # pragma: no cover - depends on external database.
        return DatabaseCheckResult(
            configured=True,
            ok=False,
            message=f"Database connection failed: {exc.__class__.__name__}",
        )

    return DatabaseCheckResult(
        configured=True,
        ok=True,
        message="Database connection succeeded.",
    )
