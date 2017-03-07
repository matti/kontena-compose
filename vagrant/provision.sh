#!/usr/bin/env sh

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y htop iotop vnstat
