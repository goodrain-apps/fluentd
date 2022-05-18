FROM fluent/fluentd:v1.14.6-debian-1.0

LABEL maintainer="Eduardo Silva <eduardo@treasure-data.com>"
USER root
WORKDIR /home/fluent
ENV PATH /fluentd/vendor/bundle/ruby/2.7.0/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/2.7.0
ENV GEM_HOME /fluentd/vendor/bundle/ruby/2.7.0
# skip runtime bundler installation
ENV FLUENTD_DISABLE_BUNDLER_INJECTION 1


COPY Gemfile* /fluentd/
RUN sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN buildDeps="sudo make gcc g++ libc-dev libffi-dev build-essential autoconf automake libtool pkg-config curl" \
  runtimeDeps="krb5-kdc libsasl2-modules-gssapi-mit libsasl2-dev" \
     && export DEBIAN_FRONTEND=noninteractive && apt-get update \
     && apt-get upgrade -y \
     && apt-get install \
     -y --no-install-recommends \
     $buildDeps $runtimeDeps net-tools \
    && gem install bundler --version 2.2.24 \
    && bundle config silence_root_warning true \
    && bundle install --gemfile=/fluentd/Gemfile --path=/fluentd/vendor/bundle \
    && curl -sL -o columnify_0.1.0_Linux_x86_64.tar.gz https://github.com/reproio/columnify/releases/download/v0.1.0/columnify_0.1.0_Linux_x86_64.tar.gz \
    && tar xf columnify_0.1.0_Linux_x86_64.tar.gz \
    && rm LICENSE README.md columnify_0.1.0_Linux_x86_64.tar.gz \
    && mv columnify /usr/local/bin/ \
    && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
    && gem sources --clear-all \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem \
    && ldd $(gem contents rdkafka | grep librdkafka.so) | grep libsasl2.so.2

# Copy configuration files
COPY ./conf/fluent.conf /fluentd/etc/
COPY ./conf/systemd.conf /fluentd/etc/
COPY ./conf/kubernetes.conf /fluentd/etc/
COPY ./conf/prometheus.conf /fluentd/etc/
COPY ./conf/tail_container_parse.conf /fluentd/etc/
COPY ./conf/kubernetes/*.conf /fluentd/etc/kubernetes/
RUN touch /fluentd/etc/disable.conf

# Copy plugins
COPY plugins /fluentd/plugins/
COPY entrypoint.sh /fluentd/entrypoint.sh

# Environment variables
ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

# Overwrite ENTRYPOINT to run fluentd as root for /var/log / /var/lib
ENTRYPOINT ["tini", "--", "/fluentd/entrypoint.sh"]
