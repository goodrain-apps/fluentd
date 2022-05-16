#!/bin/bash


export SERVICE_NAME=nginx
export ES_ADDR=http://9200.gr8ed95a.duaqtz0k.17f4cc.grapps.cn/
export ES_USER=elastic
export ES_PASS=MagicWord
export SERVICE_LOGS=/var/log/nginx/access.log,/var/log/nginx/error.log

auto_envsubst_test(){
    defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
    template=/fluent.conf
    output_path=/fluentd/etc/fluent.conf
    envsubst "$defined_envs" < "$template" > "$output_path"
}
auto_envsubst_test

echo "$(sed 's/[0-9].*/114.114.114.114/g' /etc/resolv.conf)" > /etc/resolv.conf
fluentd -c /fluentd/etc/fluent.conf
