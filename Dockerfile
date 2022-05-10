FROM registry.cn-shanghai.aliyuncs.com/samaritan/fluentd:1.14-1

USER root
RUN apk add --update libintl && apk add --virtual build_deps gettext
COPY templates/* /
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

ENTRYPOINT ["sh","docker-entrypoint.sh"] 

