ARG UNISON_VERSION=2.53.7
ARG ALPINE_VERSION=3.21.3

FROM alpine:${ALPINE_VERSION} AS builder
ARG UNISON_VERSION

# Install packages

ENV TZ=Europe/Rome

RUN apk add --no-cache \
    bash \
    curl \
    fcgiwrap \
    g++ \
    gcc \
    libc-dev \
    linux-headers \
    make \
    musl-dev \
    mutt \
    ocaml \
    procps \
    pwgen \
    shadow \
    ssmtp \
    tzdata \
    # Download & Install Unison
    && curl -L https://github.com/bcpierce00/unison/archive/refs/tags/v${UNISON_VERSION}.tar.gz | tar zxv -C /tmp \
    && cd /tmp/unison-${UNISON_VERSION} \
    && make 


FROM alpine:${ALPINE_VERSION}
ARG UNISON_VERSION

LABEL org.opencontainers.image.authors="andrea.garbato@gmail.com, PadawanNico21"
LABEL org.opencontainers.image.source="https://github.com/PadawanNico21/unicloud"

COPY --from=builder /tmp/unison-${UNISON_VERSION}/src/unison /usr/bin
COPY --from=builder /tmp/unison-${UNISON_VERSION}/src/unison-fsmonitor /usr/bin

RUN apk add --no-cache \
        bash \
        dumb-init \
        fcgiwrap \
        gcc \
        linux-headers \
        logrotate \
        musl-dev \
        mutt \
        nginx \
        openssh \
        procps \
        pwgen \
        py3-pip \
        python3 \
        python3-dev \
        shadow \
        sqlite \
        ssmtp \
        supervisor \
        tzdata && \
    pip3 install --no-cache-dir --break-system-packages \
        flask flask_restful uwsgi requests  flask-basicAuth flask-autoindex psutil apscheduler sqlalchemy && \
    apk del gcc python3-dev musl-dev linux-headers && \
    mkdir -p /var/run/sshd /run/nginx && \
    mv /etc/nginx/http.d/default.conf /etc/nginx/http.d/default.conf.install && \
    rm -f /etc/logrotate.d/* && \
    chmod 4755 /bin/su
    
COPY app /usr/local/unicloud
COPY app_client /usr/local/unicloud_client
COPY conf/sshd/sshd_config_alpine /etc/sshd_config
COPY conf/sshd/sshd_config_alpine_debug /etc/sshd_config_debug
COPY conf/nginx/default.conf /etc/nginx/http.d/default.conf
COPY conf/logrotate.d/ /etc/logrotate.d/
COPY start/ /start/

WORKDIR "/start"

EXPOSE 22
EXPOSE 80
VOLUME ["/data"]
        
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["python3","-u","start.py"]
