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
            content= vhost + ': the number of  msgs of '+ q_name + ' is ' + msg_count + ' , please take a look!'
            receiver = get_receiver(vhost)
            xiaoding = DingtalkChatbot(receiver)
            xiaoding.send_text(msg=content, is_at_all=False)
            time.sleep(2)

def get_receiver(vhost):
	receiver = ''
	return receiver


for v in get_vhost():
    get_queue_msg_count(v)
