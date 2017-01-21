#!/usr/bin/env bash
set -e

export KONTENA_VERSION=${1:-1.0.4}
export KONTENA_MASTER_URI=${2:-ws://localhost:9292}
export KONTENA_MASTER_LE_CERT_HOSTNAME=$3
export KONTENA_MASTER_LE_CERT_EMAIL=$4
export COMPOSE_PROJECT_NAME=kontena
