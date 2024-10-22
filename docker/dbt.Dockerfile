ARG build_for=linux/amd64
ARG py_version=3.12

FROM python:$py_version-slim-bullseye as base

# System setup
RUN apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y --no-install-recommends \
    build-essential=12.9 \
    ca-certificates=20210119 \
    git=1:2.30.2-1+deb11u2 \
    libpq-dev=13.16-0+deb11u1 \
    make=4.3-4.1 \
    openssh-client=1:8.4p1-5+deb11u3 \
    software-properties-common=0.96.20.2-2.1 \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Environment variables
ENV PYTHONIOENCODING=utf-8
ENV LANG=C.UTF-8

# Update python
RUN python -m pip install --upgrade pip setuptools wheel pytz --no-cache-dir

# Set docker basics
WORKDIR /usr/app/

ENTRYPOINT ["dbt"]

FROM base as dbt-bigquery
ARG commit_ref=main

RUN python -m pip install --no-cache-dir "dbt-bigquery @ git+https://github.com/dbt-labs/dbt-bigquery@${commit_ref}"
