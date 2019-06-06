#!/bin/bash
yum install expect* -y >/dev/null

read -p "user: " USER
read -p "vhost: " vhost
VHOST="$vhost"
DEV_HOST="192.168.0.5:5672"
PROD_HOST="192.168.0.5:5672"
PASSWORD=`mkpasswd -l 12 -d 3 -c 5 -C 4 -s 0`

if [ ${USER:0:4} == 'test' ]
then HOST=$DEV_HOST
else HOST=$PROD_HOST
fi
echo $HOST
# add user
rabbitmqctl  add_user $USER $PASSWORD
# add user tags
rabbitmqctl set_user_tags $USER management
# add vhost
rabbitmqctl add_vhost $VHOST
# set permissions
rabbitmqctl set_permissions -p $VHOST $USER ".*" ".*" ".*"
# set topic permissions
rabbitmqctl set_topic_permissions -p $VHOST $USER ""  ".*" ".*"
# set policy
rabbitmqctl -p $VHOST  set_policy "all" ".*" '{"ha-mode":"all","ha-sync-mode":"automatic"}'

# print
echo -e "user: $USER\npassword: $PASSWORD\nvhost: $VHOST\nhost: $HOST" >>rabbitmq
echo -e "user: $USER\npassword: $PASSWORD\nvhost: $VHOST\nhost: $HOST" 
echo "">>rabbitmq
