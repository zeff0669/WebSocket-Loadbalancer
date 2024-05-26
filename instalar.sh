#!/bin/bash
apt update -y
apt upgrade -y
apt install haproxy -y

echo "
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

    # Limite de recursos
    # maxconn 2000

defaults
    log     global
    option  tcplog
    timeout connect 5000ms
    timeout client  50000ms
    timeout server  50000ms
    timeout tunnel  3600s  # Importante para WebSocket
    timeout client-fin 30s
    timeout server-fin 30s
    option redispatch
    retries 3

frontend WebSocket_front
    bind *:8080
    mode tcp
    default_backend WebSocket_back

backend WebSocket_back
    mode tcp
    balance leastconn
    server server1 127.0.0.1:77 check
    server server2 127.0.0.1:78 check
    server server3 127.0.0.1:79 check
" > /tmp/arquivo.cfg
