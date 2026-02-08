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

if [ $# -lt 1 ]; then
    echo "❌ Error: Please provide the backup timestamp"
    echo "📋 Usage: $0 <TIMESTAMP> [DATABASE]"
    echo "📋 Examples:"
    echo "   $0 20260204_195603 studio    # Restore only studio database"
    echo "   $0 20260204_195603 metabase  # Restore only metabase database"
    echo "   $0 20260204_195603 all       # Restore both databases and volumes"
    echo ""
    echo "📂 Available backups:"
    ls -1 ./backups/*.tar.gz 2>/dev/null | sed 's/.*_\([0-9]\{8\}_[0-9]\{6\}\)\.tar\.gz/\1/' | sort -u
    exit 1
fi

TIMESTAMP=$1
DATABASE=${2:-"all"}  # Default to "all" if not specified
BACKUP_DIR="./backups"

echo "🔄 Starting Docker volumes restore..."
echo "📁 Backup directory: $BACKUP_DIR"
echo "⏰ Timestamp: $TIMESTAMP"
echo "🎯 Target database: $DATABASE"
echo "================================"

# Stop containers before starting restore
echo "⏹️  Stopping all containers..."
docker compose stop

# Project Volume List
VOLUMES=(
    "studio_script_pgdata"
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

# Restore SQL Dumps based on DATABASE parameter
echo "================================"
echo "🔄 Restarting containers..."
docker compose up -d

# Wait a few seconds for Postgres to be ready
echo "⏳ Waiting for Database to be ready..."
sleep 5

# Restore Studio Database
if [ "$DATABASE" = "all" ] || [ "$DATABASE" = "studio" ]; then
    STUDIO_DUMP="${BACKUP_DIR}/studio_dump_${TIMESTAMP}.sql"
    if [ -f "$STUDIO_DUMP" ]; then
        echo "🐘 Restoring Studio Database..."
        cat "$STUDIO_DUMP" | docker exec -i studio_postgres psql -U "$POSTGRES_USER" -d "$STUDIO_DB"
        echo "✅ Studio Database restore completed!"
    else
        echo "⚠️  Studio dump file not found: $STUDIO_DUMP"
    fi
fi

# Restore Metabase Database
if [ "$DATABASE" = "all" ] || [ "$DATABASE" = "metabase" ]; then
    METABASE_DUMP="${BACKUP_DIR}/metabase_dump_${TIMESTAMP}.sql"
    if [ -f "$METABASE_DUMP" ]; then
        echo "🐘 Restoring Metabase Database..."
        cat "$METABASE_DUMP" | docker exec -i studio_postgres psql -U "$POSTGRES_USER" -d "$METABASE_DB"
        echo "✅ Metabase Database restore completed!"
    else
        echo "⚠️  Metabase dump file not found: $METABASE_DUMP"
    fi
fi

echo "================================"
echo "🎉 Restore completed successfully!"
echo "📊 Database restored: $DATABASE"