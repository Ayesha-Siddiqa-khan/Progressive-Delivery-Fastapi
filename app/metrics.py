"""Prometheus metrics for release analysis."""

from collections.abc import Awaitable, Callable
from time import perf_counter

from fastapi import Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest
from starlette.middleware.base import BaseHTTPMiddleware

from app.settings import get_settings

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests handled by the FastAPI app.",
    ["method", "path", "status_code", "app_version", "release_mode"],
)

ERROR_COUNT = Counter(
    "http_errors_total",
    "Total HTTP responses with status code 500 or greater.",
    ["method", "path", "status_code", "app_version", "release_mode"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds.",
    ["method", "path", "app_version", "release_mode"],
    buckets=(0.025, 0.05, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 10.0),
)


class PrometheusMetricsMiddleware(BaseHTTPMiddleware):
    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        settings = get_settings()
        path = request.url.path
        start = perf_counter()
        status_code = 500

        try:
            response = await call_next(request)
            status_code = response.status_code
            return response
        except Exception:
            status_code = 500
            raise
        finally:
            elapsed = perf_counter() - start
            labels = {
                "method": request.method,
                "path": path,
                "status_code": str(status_code),
                "app_version": settings.app_version,
                "release_mode": settings.release_mode,
            }
            REQUEST_COUNT.labels(**labels).inc()
            if status_code >= 500:
                ERROR_COUNT.labels(**labels).inc()
            REQUEST_LATENCY.labels(
                method=request.method,
                path=path,
                app_version=settings.app_version,
                release_mode=settings.release_mode,
            ).observe(elapsed)


def metrics_response() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
