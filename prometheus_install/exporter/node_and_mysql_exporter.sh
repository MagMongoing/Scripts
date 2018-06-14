#!/bin/bash
# must run as root
# author: Magbon
# date: 2017-07-28
mv /home/dba/mysqld_exporter-0.10.0.linux-amd64.tar.gz /home/dba/node_exporter-0.14.0.linux-amd64.tar.gz /usr/local/src
mkdir /usr/local/prometheus_exporter

cd /usr/local/src

tar -xzf mysqld_exporter-0.10.0.linux-amd64.tar.gz -C ../prometheus_exporter/
tar -xzf node_exporter-0.14.0.linux-amd64.tar.gz -C ../prometheus_exporter/

cd ../prometheus_exporter/
mv mysqld_exporter-0.10.0.linux-amd64 mysqld_exporter
mv node_exporter-0.14.0.linux-amd64 node_exporter

cat >/etc/systemd/system/mysqld_exporter.service<<EOF
[Unit]
Description=mysqld_exporter
After=network.target
[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/prometheus_exporter/mysqld_exporter/mysqld_exporter  --config.my-cnf=/usr/local/prometheus_exporter/mysqld_exporter/.my.conf
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

cat >/etc/systemd/system/node_exporter.service<<EOF
[Unit]
Description=node_exporter
After=network.target
[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/prometheus_exporter/node_exporter/node_exporter
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

cat >/usr/local/prometheus_exporter/mysqld_exporter/.my.conf<<EOF
[client]
user=
password=
host=127.0.0.1
port=
EOF
useradd prometheus

read -s -p "please enter the mysql PASS: " PASS
mysql -uroot -p$PASS <<EOF
create user @127.0.0.1 identified by '';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO ''@'127.0.0.1';
GRANT SELECT ON performance_schema.* TO ''@'127.0.0.1';
EOF


#systemctl start node_exporter
#systemctl start mysqld_exporter

