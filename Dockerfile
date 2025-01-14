##### Base Setup #####

# Apply python base image
FROM python:3.8-alpine3.13 as python-base

RUN apk add --update \
    curl gnupg ca-certificates \
    && rm -rf /var/cache/apk/*

# Install extra libraries
RUN apk add --no-cache boost-dev ca-certificates gcc g++ libffi-dev libressl-dev musl-dev openssl

##### App Environment Setup #####

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VERSION=1.1.8 \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv" \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1
# See the Github issues below for more context into CRYPTOGRAPHY_DONT_BUILD_RUST=1 as dependencies change
# https://github.com/python-poetry/poetry/issues/3661
# https://github.com/pyca/cryptography/issues/5771

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# Install Poetry (uses $POETRY_HOME & $POETRY_VERSION environment variables)
RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | python -

# Copy Python requirements and install only runtime dependencies
WORKDIR $PYSETUP_PATH
COPY ./poetry.lock ./pyproject.toml ./
RUN poetry install --no-dev

# Set active directory
WORKDIR /app

# Add non-root user
RUN adduser --disabled-password --gecos '' appuser

# Copy application code dependencies
COPY /conf/start.sh /conf/test_runner.sh ./
COPY /app ./app

# Assign non-root user permissions
RUN chown appuser /app /app/*

# Assign start shell script permission privilege to non-root user
RUN chmod +x /app/start.sh /app/test_runner.sh

# Constrain application layer to setting non-root and default command
FROM python-base as application

# Set non-root user
USER appuser

# Set default command to start app shell
CMD ["/app/start.sh"]

###### Test-Builder Layer #####

# "testing" stage uses "python-base" stage and adds test dependencies to execute test script
FROM python-base as testing

# Install full poetry environment including dev-dependencies for test libraries
WORKDIR $PYSETUP_PATH
RUN poetry install

# Set active directory and copy test dependencies
WORKDIR /app
COPY /tests ./tests

# Set non-root user
USER appuser

# Set default command to run tests
CMD ["/app/test_runner.sh"]
