####################################################################################
# builder: compiles nagios core and plugins into /opt/nagios-<version>
####################################################################################
FROM alpine:3 AS builder

RUN apk add --no-cache \
        bash \
        build-base \
        gd-dev \
        iputils \
        linux-headers \
        openssl-dev \
        perl \
        procps \
        unzip \
        && \
    addgroup -g 1000 nagios && \
    adduser -D -H -u 1000 -G nagios -h /opt/nagios -s /bin/bash nagios

# ADD extracts local archives, so only their content ends up in the build stage
ADD nagios.tgz nagios-plugins.tgz /tmp/build/

# install into the versioned folder through the /opt/nagios symlink,
# so all paths in the generated config refer to the unversioned /opt/nagios
RUN cd /tmp/build/nagios-[0-9]* && \
    mkdir -p "/opt/$(basename "$PWD")" && \
    ln -s "/opt/$(basename "$PWD")" /opt/nagios && \
    ./configure \
        --prefix=/opt/nagios \
        --with-nagios-user=nagios \
        --with-nagios-group=nagios \
        --with-command-group=nagios \
        && \
    make all && \
    make install install-commandmode install-config && \
    sed -i 's#| /usr/sbin/sendmail -s #| /usr/local/bin/nagios-send-mail #' /opt/nagios/etc/objects/commands.cfg && \
    sed -i 's#^cfg_file=/opt/nagios/etc/objects/localhost.cfg$#\#&#' /opt/nagios/etc/nagios.cfg

RUN cd /tmp/build/nagios-plugins-[0-9]* && \
    ./configure \
        --prefix=/opt/nagios \
        --with-nagios-user=nagios \
        --with-nagios-group=nagios \
        && \
    make && \
    make install

####################################################################################
# base: build results and the nagios user, shared by daemon and web image
####################################################################################
FROM alpine:3 AS base
LABEL org.opencontainers.image.authors="outrage_breath.0t@icloud.com"

RUN apk add --no-cache \
        bash \
        gd \
        libssl3 \
        tzdata \
        && \
    addgroup -g 1000 nagios && \
    adduser -D -H -u 1000 -G nagios -h /opt/nagios -s /bin/bash nagios

COPY --from=builder /opt/ /opt/

# override with e.g. TZ=Europe/Vienna
ENV TZ=UTC
WORKDIR /opt/nagios

####################################################################################
# nagios-web: serves the web interface (share/ and the CGIs in sbin/)
# needs etc/ and var/ shared with the nagios daemon container
####################################################################################
FROM base AS nagios-web

RUN apk add --no-cache \
        lighttpd \
        lighttpd-mod_auth \
        php-cgi

COPY web/lighttpd.conf /etc/lighttpd/nagios.conf
COPY --chmod=755 web/entrypoint.sh /opt/nagios-web-entrypoint.sh

USER nagios
EXPOSE 8080
# everything below /nagios/ requires a login, so 401 means lighttpd is up and answering
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --start-interval=5s --retries=3 \
    CMD wget -q -S -T 5 --spider http://127.0.0.1:8080/nagios/ 2>&1 | grep -q "HTTP/1.1 401"
ENTRYPOINT ["/opt/nagios-web-entrypoint.sh"]
CMD ["lighttpd", "-D", "-f", "/etc/lighttpd/nagios.conf"]

####################################################################################
# nagios: the monitoring daemon with plugins (default target)
####################################################################################
FROM base AS nagios

RUN apk add --no-cache \
        iputils \
        msmtp \
        perl \
        perl-io-socket-ssl \
        procps

# every file in daemon/scripts/ ends up executable in /usr/local/bin under the same name
COPY --chmod=755 daemon/scripts/ /usr/local/bin/
COPY --chmod=755 daemon/entrypoint.sh /opt/nagios-entrypoint.sh

USER nagios
# daemon process is running and has written status.dat within the last minute
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --start-interval=5s --retries=3 \
    CMD /opt/nagios/libexec/check_nagios -F /opt/nagios/var/status.dat -e 1 -C /opt/nagios/bin/nagios
ENTRYPOINT ["/opt/nagios-entrypoint.sh"]
CMD ["/opt/nagios/bin/nagios", "/opt/nagios/etc/nagios.cfg"]
