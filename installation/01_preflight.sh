#!/usr/bin/env bash
set -euo pipefail
cat /etc/os-release
uname -m
free -h
df -h
command -v pg_lsclusters >/dev/null && pg_lsclusters || true
ss -lnt | grep ':5432 ' || true
