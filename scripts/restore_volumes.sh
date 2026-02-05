#!/bin/bash
# Script to restore Project Docker volumes and database

set -e

# 1. Load environment variables from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "🔑 Environment variables loaded from .env"
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "❌ Error: Please provide the backup timestamp"
    echo "📋 Usage: $0 <TIMESTAMP>"
    echo "📋 Example: $0 20260204_195603"
    echo ""
    echo "📂 Available backups:"
    ls -1 ./backups/*.tar.gz 2>/dev/null | sed 's/.*_\([0-9]\{8\}_[0-9]\{6\}\)\.tar\.gz/\1/' | sort -u
    exit 1
fi

TIMESTAMP=$1
BACKUP_DIR="./backups"

echo "🔄 Starting Docker volumes restore..."
echo "📁 Backup directory: $BACKUP_DIR"
echo "⏰ Timestamp: $TIMESTAMP"
echo "================================"

# Stop containers before starting restore
echo "⏹️  Stopping all containers..."
docker compose stop

# Project Volume List
VOLUMES=(
    "studio_script_pgdata"
    "studio_script_metabase-data"
)

for volume in "${VOLUMES[@]}"; do
    BACKUP_FILE="${BACKUP_DIR}/${volume}_${TIMESTAMP}.tar.gz"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        echo "⚠️  Backup file not found for volume: $volume. Skipping..."
        continue
    fi
    
    echo "📦 Restoring volume: $volume"
    
    # Remove current volume
    echo "🗑️  Removing existing volume..."
    docker volume rm "$volume" 2>/dev/null || true
    
    # Create new volume
    docker volume create "$volume"
    
    # Restore data using busybox
    echo "📥 Extracting data..."
    docker run --rm \
        -v "$volume":/data \
        -v "$(pwd)/$BACKUP_DIR":/backup \
        busybox tar xzf /backup/"${volume}_${TIMESTAMP}.tar.gz" -C /data
    
    echo "✅ Restore completed for: $volume"
done

# Restart containers to apply volume changes
echo "================================"
echo "🔄 Restarting containers..."
docker compose up -d

# Wait a few seconds for Postgres to be ready
echo "⏳ Waiting for Database to be ready..."
sleep 5

# Restore SQL Dump if it exists
SQL_DUMP="${BACKUP_DIR}/db_dump_${TIMESTAMP}.sql"
if [ -f "$SQL_DUMP" ]; then
    echo "🐘 SQL Dump found! Restoring database structure..."
    cat "$SQL_DUMP" | docker exec -i studio_postgres psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"
    echo "✅ SQL Restore completed!"
fi

echo "================================"
echo "🎉 Full restore completed successfully!"