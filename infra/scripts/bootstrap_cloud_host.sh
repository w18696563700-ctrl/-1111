#!/usr/bin/env bash
set -euo pipefail

dnf update -y
dnf install -y dnf-plugins-core git curl wget jq tar unzip zip rsync lsof nginx

if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
  dnf install -y nodejs
fi

if ! command -v docker >/dev/null 2>&1; then
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo || true
  dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
fi

npm install -g pnpm pm2 @nestjs/cli

mkdir -p /srv/apps/bff /srv/apps/server /srv/shared /srv/releases
systemctl enable --now nginx || true
systemctl enable --now docker || true

echo "cloud bootstrap completed"
