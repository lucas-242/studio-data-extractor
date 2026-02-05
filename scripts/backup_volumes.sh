#!/bin/bash
# Script to backup Project Docker Volumes and Database Dump

set -e

# Load environment variables from .env file
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
    echo "🔑 Environment variables loaded from .env"
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "🔄 Starting backup process..."
echo "================================"

# Database SQL Dump (Using variables from .env)
echo "🐘 Creating Database SQL Dump..."
docker exec studio_postgres pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB" > "$BACKUP_DIR/db_dump_${TIMESTAMP}.sql"
echo "✅ SQL Dump completed!"

# Docker Volumes Backup (Physical files)
VOLUMES=(
    "studio_script_pgdata"
    "studio_script_metabase-data"
)

for volume in "${VOLUMES[@]}"; do
    echo "📦 Backing up volume: $volume"
    
    docker run --rm \
        -v "$volume":/data \
        -v "$(pwd)/$BACKUP_DIR":/backup \
        busybox tar czf /backup/"${volume}_${TIMESTAMP}.tar.gz" -C /data .
    
    echo "✅ Backup completed: ${volume}_${TIMESTAMP}.tar.gz"
done

echo "================================"
echo "🎉 Backup successful! Files saved in: $BACKUP_DIR"
ls -lh "$BACKUP_DIR"/*_"$TIMESTAMP".*