ARG PYTHON_BASE_IMAGE=3.11-slim-bookworm
ARG APP_NAME=python_template

#
# Stage: staging
#
FROM python:${PYTHON_BASE_IMAGE} AS staging

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1

# TODO: Is this important ?
# ENV PYTHONPATH="/workspace/src/$APP_NAME:$PYTHONPATH"

# The virtual environment is created in the working directory where rye is run
# so the development and production environments must be in the same directory respectively.
WORKDIR /workspace

RUN \
    --mount=type=cache,target=/var/lib/apt/lists \
    --mount=type=cache,target=/var/cache/apt/archives \
    apt-get update \
    && apt-get install -y --no-install-recommends \
    curl \
    build-essential

ENV RYE_HOME="/opt/rye"
ENV PATH="$RYE_HOME/shims:$PATH"

# RYE_INSTALL_OPTION is required to build.
# See: https://github.com/mitsuhiko/rye/issues/246
RUN curl -sSf https://rye-up.com/get | RYE_NO_AUTO_INSTALL=1 RYE_INSTALL_OPTION="--yes" bash

# Download dependencies as a separate step to take advantage of Docker's caching.
# Leverage a bind mount to some files to avoid having to copy them into this layer.
RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=requirements.lock,target=requirements.lock \
    --mount=type=bind,source=requirements-dev.lock,target=requirements-dev.lock \
    --mount=type=bind,source=.python-version,target=.python-version \
    --mount=type=bind,source=README.md,target=README.md \
    rye sync --no-dev --no-lock

RUN . .venv/bin/activate

#
# Stage: development
#
FROM staging AS development
# The development environment assumes a devcontainer and the environment is
# closed inside the container, so you don't need to be aware of the virtual environment

# RUN --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
#     --mount=type=bind,source=requirements.lock,target=requirements.lock \
#     --mount=type=bind,source=requirements-dev.lock,target=requirements-dev.lock \
#     --mount=type=bind,source=.python-version,target=.python-version \
#     --mount=type=bind,source=README.md,target=README.md \
#     rye sync --no-lock

COPY pyproject.toml requirements.lock requirements-dev.lock .python-version README.md ./
RUN rye sync --no-lock
COPY . .

# ENTRYPOINT [ "/bin/bash", "-c"]

#
# Stage: production
#
FROM staging AS production

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
ARG UID=10001
ARG APP_NAME

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser

# Switch to the non-privileged user to run the application.
USER appuser

# COPY . .

# TODO: Directly use requirements file with pip
# RUN sed '/-e/d' requirements.lock > requirements.txt
# RUN pip install -r requirements.txt

# export APP_NAME as environment variable for the CMD
# ENV APP_NAME=$APP_NAME
# CMD ["sh", "-c", "$APP_NAME"]
