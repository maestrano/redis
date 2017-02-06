FROM redis:3.2

RUN set -x \
  && mkdir -p /usr/local/etc/redis \
  && touch /usr/local/etc/redis/redis.conf \
  && chown redis:redis /usr/local/etc/redis/redis.conf

ENV REDIS_PASS **None**

# Entrypoint script
# Entrypoint directive is specified in inherited image
COPY docker-entrypoint.sh /usr/local/bin/

# Healthcheck
COPY healthcheck.sh /usr/local/bin/
HEALTHCHECK --timeout=5s CMD bash /usr/local/bin/healthcheck.sh

# Default start
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
