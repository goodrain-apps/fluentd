#!/bin/bash


out_file(){                        
echo "
<match **>
@type elasticsearch
logstash_format true
log_level info
include_tag_key true
hosts ${ES_HOST}
port ${ES_PORT}
user ${ES_USERNAME}
password ${ES_PASSWORD}
index_name k8s_
  <buffer tag>     # 缓冲区配置项
    @type file
    path /var/log/buffer/${tag}.log       
    chunk_limit_size 512M      # 缓冲区文件的容量
    total_limit_size 64G       # 缓冲区最大的容量
    queue_limit_length 256     # 列队数，当缓冲区的文件容量超过限制时，会被放到队列中，等待flush
    flush_interval 60s
    retry_max_times 30  # 重试flush失败块的此=次数
    disable_retry_limit false   # 消息自动重发策略
    retry_wait 1s       # 重试等待时间
    retry_max_times 20   # 重试次数
  </buffer>
</match>" >> /fluent.conf
}

if [ $SERVICE_NAME == "nginx" ]; then
    cat nginx.yml > /fluent.conf
    out_file
elif [ $SERVICE_NAME == "mysql" ]; then
    cat mysql.yml > /fluent.conf
    out_file
elif [ $SERVICE_NAME == "apache2" ]; then
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
