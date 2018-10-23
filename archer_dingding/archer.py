#! /usr/bin/env python
# -*- coding:utf-8 -*-
import configparser
import pymysql
import time

from dingtalkchatbot.chatbot import DingtalkChatbot


config = configparser.ConfigParser()
config.read('config.ini')
port = int(config.get('mysql', 'port'))
username = config.get('mysql', 'user')
password = config.get('mysql', 'password')
host = config.get('mysql', 'host')
robot = config.get('dingding', 'robot')
dev_group = config.get('dingding', 'group')

connection = pymysql.connect(host=host, user=username, password=password, port=port, charset='utf8mb4', db='archer')

cursor = connection.cursor()
ding_time = int(time.time()) - 60
sql = "select engineer,workflow_name,review_man,status,cluster_name from sql_workflow where ding_time>=from_unixtime({0})".format(ding_time)
cursor.execute(sql)
result = cursor.fetchall()

if result != None:
	for row in result:
		content = row[0] + '发起工单：' + row[1] + '\n审核人：' + row[2] + '\n上线集群: ' + row[4] + '\n工单状态：' + row[3]
		ding = DingtalkChatbot(robot)
		ding.send_text(msg=content,is_at_all=False)
		ding = DingtalkChatbot(dev_group)
		ding.send_text(msg=content,is_at_all=False)

connection.close()
