

LOCALIP=`ifconfig eth0 |grep "inet "|awk '{print $2}'`
RABBITMQ_HTTP_PORT=15672
RABBIT_PASSWORD=
RABBIT_USER=

yum install lsof -y

lsof -i:9090

if [ $? -eq 0 ]
	then echo "port: 9090 is being used!"
	else

		ps -ef|grep docker |grep -v "grep"

		if [ $? -eq 0 ] 
			then 
				docker run -d   -e RABBIT_CAPABILITIES=bert,no_sort -e PUBLISH_PORT=9090  -e RABBIT_USER=$RABBIT_USER -e  RABBIT_PASSWORD=$RABBIT_PASSWORD -e RABBIT_URL=http://$LOCALIP:$RABBITMQ_HTTP_PORT  -p 9090:9090    kbudde/rabbitmq-exporter	
		        else
				yum install docker -y
				systemctl start docker
				docker run -d   -e RABBIT_CAPABILITIES=bert,no_sort -e PUBLISH_PORT=9090  -e RABBIT_USER=$RABBIT_USER -e  RABBIT_PASSWORD=$RABBIT_PASSWORD -e RABBIT_URL=http://$LOCALIP:$RABBITMQ_HTTP_PORT  -p 9090:9090    kbudde/rabbitmq-exporter
		fi
fi
