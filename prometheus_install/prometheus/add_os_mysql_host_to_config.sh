#!/bin/bash

#echo "Please enter the host IP: "
read -p  "Please enter the host IP: " IP
read -p  "Please enter the OS job name: "  os_job
read -p  "Please enter the mysql job name: " mysql_job
cat >>/etc/prometheus/prometheus.yml<<EOF

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['$IP:9100']
        labels:
          instance: $os_job
  - job_name: 'mysqld_exporter'
    static_configs:
      - targets: ['$IP:9104']
        labels:
          instance: $mysql_job
EOF

systemctl restart prometheus
