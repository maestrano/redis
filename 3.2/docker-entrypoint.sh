#!/bin/bash
set -e

# Set config variables
conf_file=/usr/local/etc/redis/redis.conf

# Configure AOF persistence by default
# (persist across restarts)
if grep -q appendonly $conf_file; then
  echo "appendonly yes" >> $conf_file
fi

# Set Redis pass if defined
if [ "${REDIS_PASS}" != "**None**" ] && ! grep -q 'requirepass' $conf_file; then
  echo "requirepass $REDIS_PASS" >> $conf_file
fi

# Configure replication
# If SELF_HOST and SELF_PORT are set then we also ensure to not configure
# replication on itself
if [ "$REDIS_MASTER" ] && [ "$SELF_HOST:$SELF_PORT" != "$REDIS_MASTER" ]; then
  master=(${REDIS_MASTER//:/ })
  echo "slaveof ${master[0]} ${master[1]}" >> $conf_file

  if [ "${REDIS_PASS}" != "**None**" ] && ! grep -q 'masterauth' $conf_file; then
    echo "masterauth $REDIS_PASS" >> $conf_file
  fi
fi

# first arg is `-f` or `--some-option`
# or first arg is `something.conf`
if [ "${1#-}" != "$1" ] || [ "${1%.conf}" != "$1" ]; then
	set -- redis-server "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'redis-server' -a "$(id -u)" = '0' ]; then
	chown -R redis .
	exec gosu redis "$0" "$@"
fi

if [ "$1" = 'redis-server' ]; then
	# Disable Redis protected mode [1] as it is unnecessary in context
	# of Docker. Ports are not automatically exposed when running inside
	# Docker, but rather explicitely by specifying -p / -P.
	# [1] https://github.com/antirez/redis/commit/edd4d555df57dc84265fdfb4ef59a4678832f6da
	doProtectedMode=1
	configFile=
	if [ -f "$2" ]; then
		configFile="$2"
		if grep -q '^protected-mode' "$configFile"; then
			# if a config file is supplied and explicitly specifies "protected-mode", let it win
			doProtectedMode=
		fi
	fi
	if [ "$doProtectedMode" ]; then
		shift # "redis-server"
		if [ "$configFile" ]; then
			shift
		fi
		set -- --protected-mode no "$@"
		if [ "$configFile" ]; then
			set -- "$configFile" "$@"
		fi
		set -- redis-server "$@" # redis-server [config file] --protected-mode no [other options]
		# if this is supplied again, the "latest" wins, so "--protected-mode no --protected-mode yes" will result in an enabled status
	fi
fi

exec "$@"
