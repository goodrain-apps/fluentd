#!/bin/bash


auto_envsubst_test(){
    defined_envs=$(printf '${%s} ' $(env | cut -d= -f1))
    template=/fluent.conf
    output_path=/fluentd/etc/fluent.conf
    envsubst "$defined_envs" < "$template" > "$output_path"
}
auto_envsubst_test


fluentd -c /fluentd/etc/fluent.conf
