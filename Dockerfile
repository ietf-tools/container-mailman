FROM alpine:3.21

USER root

ENV MAILMAN_VERSION 3.3.10
ENV MAILARCHIVE_VERSION git+https://github.com/sargeant/mailman-mailarchive.git@v1.1.1

RUN apk update \
    && apk add --virtual build-deps gcc python3-dev musl-dev linux-headers \
    && apk add --no-cache bash su-exec curl python3 py3-pip lynx tzdata \
    sqlite git postgresql17-client py3-psycopg2 postfix \
    && python3 -m pip install --break-system-packages -U pip setuptools wheel \
        && python3 -m pip install --break-system-packages \
                   mailman==${MAILMAN_VERSION} \
                   ${MAILARCHIVE_VERSION} \
                   'importlib-resources<6.0.0' \
    && apk del build-deps \
    && adduser -S mailman

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt/mailman

EXPOSE 8001 8024

ENV MAILMAN_CONFIG_FILE=/etc/mailman.cfg

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["master", "--force"]
