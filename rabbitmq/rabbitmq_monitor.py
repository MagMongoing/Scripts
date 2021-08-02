#! /usr/bin/env python
# -*- coding:utf-8 -*-
import os
from dingtalkchatbot.chatbot import DingtalkChatbot
import time

def get_vhost():
    vhost = os.popen('rabbitmqctl list_vhosts').read().split("\n")[1:-1]
    return vhost

def get_queue_msg_count(vhost):
    os.environ['vhost'] = str(vhost)
    queues = os.popen("rabbitmqctl list_queues -p $vhost").read().split("\n")[2:-1]
    for i in range(0, len(queues)):
        msg_count = queues[i].split('\t')[1]
        q_name = queues[i].split('\t')[0]
        if int(msg_count) >= 100:
            content= 'Vhost: ' + vhost + '\nQueue: '+ q_name + '\nNumber of messages: ' + msg_count 
            #content = vhost 
            #print(type(content))
            receiver = get_receiver(vhost)
            xiaoding = DingtalkChatbot(receiver)
            xiaoding.send_text(msg=content, is_at_all=False)
            xiaoding = DingtalkChatbot(receiver2)
            xiaoding.send_text(msg=content, is_at_all=False)
            time.sleep(2)

def get_receiver(vhost):
	receiver = ''
	if vhost in []:
		receiver = 
	else:
		receiver = 
	return receiver


for v in get_vhost():
    get_queue_msg_count(v)
