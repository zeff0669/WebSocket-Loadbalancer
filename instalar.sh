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

mkdir /etc/SSHPlus
mkdir /opt/sshplus
echo > /opt/sshplus/sshplus
cd /etc/SSHPlus/ && wget https://github.com/zeff0669/cleancore/raw/main/WebSocket && wget https://github.com/zeff0669/cleancore/raw/main/pub.key && wget https://github.com/zeff0669/cleancore/raw/main/priv.pem && chmod +X WebSocket && cd -

echo "
[Unit]
Description=WebSocket Service
After=network.target

[Service]
ExecStart=/etc/SSHPlus/WebSocket -proxy_port 0.0.0.0:77 -listem_port 127.0.0.1:22 -msg=CleanCoreWS1
TasksMax=infinity
Restart=always

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/websocket.service
echo "
[Unit]
Description=WebSocket Service
After=network.target

[Service]
ExecStart=/etc/SSHPlus/WebSocket -proxy_port 0.0.0.0:78 -listem_port 127.0.0.1:22 -msg=CleanCoreWS2
TasksMax=infinity
Restart=always

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/websocket2.service
echo "
[Unit]
Description=WebSocket Service
After=network.target

[Service]
ExecStart=/etc/SSHPlus/WebSocket -proxy_port 0.0.0.0:79 -listem_port 127.0.0.1:22 -msg=CleanCoreWS3
TasksMax=infinity
Restart=always

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/websocket3.service

systemctl daemon-reload
systemctl enable websocket.service
systemctl enable websocket1.service
systemctl enable websocket2.service
systemctl start websocket.service
systemctl start websocket1.service
systemctl start websocket2.service
systemctl restart haproxy



