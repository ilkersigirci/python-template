ARG BASE_IMAGE=debian:bookworm-slim
ARG PYTHON_VERSION=3.11

#
# Stage: staging
#
FROM python:${PYTHON_VERSION}-slim-bookworm AS staging

# FIXME: /bin/sh rye not found
# FROM ${BASE_IMAGE} AS staging

WORKDIR /app

RUN \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update -y \
    && apt-get install -y --no-install-recommends \
    curl \
    build-essential
    # && apt-get clean \
    # && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

ENV RYE_HOME="/opt/rye"
ENV PATH="$RYE_HOME/shims:$PATH"

RUN curl -sSf https://rye.astral.sh/get | RYE_NO_AUTO_INSTALL=1 RYE_INSTALL_OPTION="--yes" bash

# TODO: Find out the way to use local config.toml
# COPY config.toml /opt/rye/config.toml
RUN rye config --set-bool behavior.use-uv=true

#
# Stage: development
#
FROM staging AS development

WORKDIR /app

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    UV_CACHE_DIR=/opt/rye/.cache/uv

RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=requirements.lock,target=requirements.lock \
    --mount=type=bind,source=requirements-dev.lock,target=requirements-dev.lock \
    --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=README.md,target=README.md \
    --mount=type=bind,source=src,target=src \
    --mount=type=cache,target=/opt/rye/.cache/uv \
    rye sync --no-lock

COPY . .

#
# Stage: build
#
FROM staging AS build

RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=requirements.lock,target=requirements.lock \
    --mount=type=bind,source=requirements-dev.lock,target=requirements-dev.lock \
    --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=README.md,target=README.md \
    --mount=type=bind,source=src,target=src \
    rye build --wheel --clean

#
# Stage: production
#
ARG PYTHON_VERSION=3.11
FROM python:${PYTHON_VERSION}-slim-bookworm AS production

ARG UID=1001
ARG GID=1001

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_ROOT_USER_ACTION=ignore \
    UV_SYSTEM_PYTHON=1 \
    # UV_REQUIRE_HASHES=true \
    UV_NO_CACHE=1

WORKDIR /app

COPY --from=build /app/dist/*.whl ./
RUN \
    --mount=type=bind,source=requirements.lock,target=requirements.lock \
    sed '/-e/d' requirements.lock > requirements.txt \
    && pip install *.whl -r requirements.txt

# FIXME: uv can't install from wheel
# RUN python -m pip install --no-cache-dir uv==0.1.44 \
#     && uv pip install *.whl -r requirements.txt

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

RUN chown -R appuser:appuser /app

# Switch to the non-privileged user to run the application.
USER appuser
