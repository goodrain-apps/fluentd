FROM registry.cn-shanghai.aliyuncs.com/samaritan/fluentd:1.14-1

USER root
RUN echo -e http://mirrors.ustc.edu.cn/alpine/v3.12/main/ > /etc/apk/repositories
RUN apk add --update libintl && apk add --virtual build_deps gettext
COPY fluent.conf /fluent.conf
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod 755 /docker-entrypoint.sh

ENTRYPOINT ["sh","docker-entrypoint.sh"] 

