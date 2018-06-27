#!/bin/bash


# ulimit
mkdir /etc/systemd/system/rabbitmq-server.service.d

cat >/etc/systemd/system/rabbitmq-server.service.d/limits.conf<<EOF
[Svervice]
LimitNOFILE=300000
EOF

systemctl daemon-reload

systemctl restart rabbitmq-server

# veryfying the limit

$PID=`ps -ef|pgrep beam`

cat /proc/$PID/limits
