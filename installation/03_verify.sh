#!/usr/bin/env bash
set -euo pipefail
pg_lsclusters
psql --version
sudo -u postgres psql -X -p "${PGPORT:-5432}" -d postgres -v ON_ERROR_STOP=1 -c 'SELECT version(), current_user, current_database();' -c 'SHOW config_file;' -c 'SHOW hba_file;' -c 'SHOW data_directory;'
