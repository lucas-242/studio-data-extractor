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

# Database SQL Dumps (Separate backups for each database)
echo "🐘 Creating Studio Database SQL Dump..."
docker exec studio_postgres pg_dump -U "$POSTGRES_USER" "$STUDIO_DB" > "$BACKUP_DIR/studio_dump_${TIMESTAMP}.sql"
echo "✅ Studio SQL Dump completed!"

echo "🐘 Creating Metabase Database SQL Dump..."
docker exec studio_postgres pg_dump -U "$POSTGRES_USER" "$METABASE_DB" > "$BACKUP_DIR/metabase_dump_${TIMESTAMP}.sql"
echo "✅ Metabase SQL Dump completed!"

# Docker Volumes Backup (Physical files)
VOLUMES=(
    "studio_script_pgdata"
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