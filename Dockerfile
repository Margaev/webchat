FROM python:3.14-slim-trixie
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

COPY pyproject.toml /app/pyproject.toml
COPY uv.lock /app/uv.lock
RUN uv sync --locked

COPY src /app/src
COPY static /app/static

ENTRYPOINT [ "uv", "run", "uvicorn", "src.app:app", "--host", "0.0.0.0" ]
