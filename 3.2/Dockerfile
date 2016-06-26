FROM redis:3.2

RUN set -x \
  && mkdir -p /usr/local/etc/redis \
  && touch /usr/local/etc/redis/redis.conf \
  && chown redis:redis /usr/local/etc/redis/redis.conf

ENV REDIS_PASS **None**
COPY docker-entrypoint.sh /usr/local/bin/
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]
