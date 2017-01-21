#!/usr/bin/env bash
set -e

export KONTENA_VERSION=${1:-1.0.4}
export KONTENA_MASTER_HOST=${2:-localhost}
export COMPOSE_PROJECT_NAME=kontena
