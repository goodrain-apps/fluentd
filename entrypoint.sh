#!/bin/bash


out_file(){
echo "
<match **>
@type elasticsearch
logstash_format true
log_level info
include_tag_key true
hosts ${ES_ADDR}
user ${ES_USER}
password ${ES_PASS}
index_name k8s_
  <buffer>
    buffer_chunk_limit 2M
    buffer_queue_limit 32
    flush_interval 5s
    max_retry_wait 30
    disable_retry_limit
  </buffer>
</match>" >> /fluent.conf
}

if [ $value == "nginx" ]; then
    cat nginx.yml > /fluent.conf
    out_file
elif [ $value == "mysql" ]; then
    cat mysql.yml > /fluent.conf
    out_file
elif [ $value == "apache2" ]; then
    cat apache2.yml > /fluent.conf
    out_file
fi

auto_envsubst_test(){
    defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
    template=/fluent.conf
    output_path=/fluentd/etc/fluent.conf
    envsubst "$defined_envs" < "$template" > "$output_path"
}
auto_envsubst_test

fluentd -c /fluentd/etc/fluent.conf
