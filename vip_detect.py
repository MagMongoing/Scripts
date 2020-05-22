#!/usr/bin/env python3
# -*- coding:utf-8 -*-
import configparser
import pymysql
import subprocess
import redis
import time

from dingtalkchatbot.chatbot import DingtalkChatbot


config = configparser.ConfigParser()
config.read('config.ini')
user = config.get('mysql', 'user')
host = config.get('mysql', 'host')
password = config.get('mysql', 'password')
port = int(config.get('mysql', 'port'))
robot = config.get('data-center', 'test')


def send_msg_robot(msg):
    ding = DingtalkChatbot(robot)
    ding.send_text(msg=msg, is_at_all=False)


r = redis.Redis(host='127.0.0.1', port=6379, db=1)

conn = pymysql.connect(host=host, user=user, password=password, port=port, db='archery', charset='utf8mb4')
cursor = conn.cursor()

sql = "select host,instance_name from sql_instance where instance_name like '%v' and instance_name not like 'n7%' group by host limit 2"
cursor.execute(sql)
result = cursor.fetchall()

for host in result:
    time.sleep(0.2)
    cmd = "ping -c 1 " + host[0]
    vip_status = subprocess.call(cmd, shell=True)
    vip_cur_status = 1 if vip_status == 0 else 0
    key = host[1].split('-')[0] + '-vip-' + host[0]
    print(key)
    if r.get(key) is None:
        r.set(key, vip_cur_status)
        if vip_cur_status == 0:
            msg = key + ' is Down!'
            send_msg_robot(msg)
        else:
            msg = key + ' is monitored'
            send_msg_robot(msg)
    else:
        vip_pre_status = int(r.get(key))
        print(vip_pre_status)
        if vip_pre_status != vip_cur_status:
            r.set(key, vip_cur_status)
            if vip_cur_status == 0:
                msg = key + ' is Down!'
                send_msg_robot(msg)
            else:
                msg = key + ' is OK!'
                send_msg_robot(msg)
conn.close()
