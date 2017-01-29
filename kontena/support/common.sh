#!/usr/bin/env sh
set -e

if [ -f ./env ]; then
  env_contents=$(cat ./env)
  printf "Exporting environment:\n$env_contents\n"
  eval $env_contents
else
  echo "no ./env found, not exporting"
fi