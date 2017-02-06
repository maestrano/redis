#!/bin/bash
# This script must exit with:
# 0 on success
# 1 on error

# Abort if no healthcheck
[ "$NO_HEALTHCHECK" == "true" ] && exit 0

# Check read access to Redis
redis-cli -a $REDIS_PASS get somekey || exit 1
