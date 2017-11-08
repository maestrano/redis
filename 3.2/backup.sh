#!/bin/sh
#
# This script creates a full backup of the redis data store
# and rollover the backup files
#
set -e

# Configuration
BKUP_DIR=${BKUP_DIR:-"/snapshots"}
BKUP_RETENTION=${BKUP_RETENTION:-20}

# Ensure backup directory exists
mkdir -p $BKUP_DIR

# Trigger full snapshot (.rdb)
redis-cli -a $REDIS_PASS save

# Perform backup (save both .rdb dump and appendonly.aof)
cd /tmp
ts=$(date -u +"%Y-%m-%dT%H-%M-%SZ")
tar -zcf $ts.tar.gz /data
mv /tmp/$ts.tar.gz $BKUP_DIR/

# Keep limited number of backups
ls -1 $BKUP_DIR/*.tar.gz | head -n -${BKUP_RETENTION} | xargs rm -f --
