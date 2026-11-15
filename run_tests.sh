#!/usr/bin/env bash
set -euo pipefail

MYSQL_HOST="${MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"
MYSQL_USER="${MYSQL_USER:-root}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf 'Required command not found on PATH: %s\n' "$1" >&2
        exit 1
    fi
}

require_command mysql
require_command mvn

if [[ -z "${MYSQL_PASSWORD:-}" ]]; then
    if [[ -t 0 ]]; then
        read -r -s -p "MySQL password for ${MYSQL_USER}: " MYSQL_PASSWORD
        printf '\n'
    else
        printf '%s\n' "Set MYSQL_PASSWORD before running non-interactively." >&2
        exit 1
    fi
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

mysql_exec() {
    MYSQL_PWD="$MYSQL_PASSWORD" mysql \
        --host="$MYSQL_HOST" \
        --port="$MYSQL_PORT" \
        --user="$MYSQL_USER" \
        "$@"
}

printf '%s\n' "Loading the MySQL schema and synthetic seed (this resets attendance_db)..."
mysql_exec < schema.sql
mysql_exec < docs/testing/data/seed.sql

shopt -s nullglob
verification_scripts=(docs/testing/data/verify_*.sql)
if (( ${#verification_scripts[@]} == 0 )); then
    printf '%s\n' "No SQL verification scripts found." >&2
    exit 1
fi

printf '%s\n' "Running MySQL verification scripts..."
for script in "${verification_scripts[@]}"; do
    printf '  %s\n' "$script"
    mysql_exec < "$script"
done

printf '%s\n' "Running Maven tests..."
mvn -B test
