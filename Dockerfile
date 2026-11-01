FROM alpine:3.24

USER root

ENV MAILMAN_VERSION git+https://gitlab.com/mailman/mailman.git@7a36c91bdcf88edb2e0c84ae0d579daf856e8f20
ENV MAILARCHIVE_VERSION git+https://github.com/ietf-tools/mailman-mailarchive.git@main
ENV IETF_STYLES_VERSION git+https://github.com/ietf-tools/mailman-ietf-styles.git@main

RUN apk update \
    && apk add --virtual build-deps gcc python3-dev musl-dev linux-headers \
    && apk add --no-cache bash su-exec curl python3 py3-pip lynx tzdata \
    sqlite git postgresql17-client py3-psycopg2 postfix \
    && python3 -m pip install --break-system-packages -U pip setuptools wheel \
        && python3 -m pip install --break-system-packages \
                   SQLAlchemy==2.0.54 \
                   psycopg \
                   prometheus_client==0.26.0 \
                   ${MAILMAN_VERSION} \
                   ${MAILARCHIVE_VERSION} \
                   ${IETF_STYLES_VERSION} \
                   'importlib-resources<6.0.0' \
    && apk del build-deps \
    && adduser -S mailman \
    && rm /etc/crontabs/root

COPY docker-entrypoint.sh /usr/local/bin/

COPY exporter.py /usr/local/bin/

WORKDIR /opt/mailman

EXPOSE 8001 8024

ENV MAILMAN_CONFIG_FILE=/etc/mailman.cfg

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["master", "--force"]
