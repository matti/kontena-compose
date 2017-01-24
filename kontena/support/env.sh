#!/usr/bin/env sh

kontena_version="latest"
kontena_master_name="composemaster"
kontena_master_uri="ws://localhost:9292"

kontena_grid_name="composegrid"
kontena_grid_initial_size="1"
kontena_grid_token="defaultinsecuregridtoken"

compose_project_name="kontena"

while [[ "$#" -gt 1 ]]; do case $1 in
    --version) kontena_version="$2";;
    --master_name) kontena_master_name="$2";;
    --master_uri) kontena_master_uri="$2";;
    --master_le_cert_hostname) kontena_le_cert_hostname="$2";;
    --master_le_cert_email) kontena_le_cert_email="$2";;
    --grid_name) kontena_grid_name="$2";;
    --grid_initial_size) kontena_grid_initial_size="$2";;
    --grid_token) kontena_grid_token="$2";;
    --compose_project_name) compose_project_name="$2";;
    *) break;;
  esac; shift; shift
done

export KONTENA_VERSION=$kontena_version
export KONTENA_MASTER_NAME=$kontena_master_name
export KONTENA_MASTER_URI=$kontena_master_uri
export KONTENA_MASTER_LE_CERT_HOSTNAME=$kontena_le_cert_hostname
export KONTENA_MASTER_LE_CERT_EMAIL=$kontena_le_cert_email
export KONTENA_GRID_NAME=$kontena_grid_name
export KONTENA_GRID_INITIAL_SIZE=$kontena_grid_initial_size
export KONTENA_GRID_TOKEN=$kontena_grid_token

export COMPOSE_PROJECT_NAME=$compose_project_name