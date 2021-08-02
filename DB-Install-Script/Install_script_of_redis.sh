#!/bin/bash

function init_env()
{
	yum install tcl -y
	echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
	sysctl vm.overcommit_memory=1
	echo never > /sys/kernel/mm/transparent_hugepage/enabled
	echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >>/etc/rc.local
	echo "net.core.somaxconn = 1024" >>/etc/sysctl.conf
	sed -i "s#net.ipv4.tcp_max_syn_backlog = 1024#net.ipv4.tcp_max_syn_backlog = 2048#" /etc/sysctl.conf
	sysctl -p
}

function package()
{
	cd /usr/local/src/
    wget http://download.redis.io/releases/redis-$DB_VERSION.tar.gz
	tar -xzf redis-$DB_VERSION.tar.gz -C ../
	cd ../redis-$DB_VERSION
	make
	useradd redis
	chown -R redis.redis ../redis-$DB_VERSION
	cd ..
	ln -s redis-$DB_VERSION  redis
	echo "PATH=$PATH:/usr/local/redis/src" >>/etc/profile
	source /etc/profile
}

function init_config_file()
{
	read -p "Please enter the PASS: " PASS

	cat >$CONFIG_DIR/"$PORT".conf<<EOF
port $PORT
dir $DIR
auto-aof-rewrite-percentage 100
daemonize yes
pidfile $PIDFILE
logfile "$LOGFILE"
tcp-backlog 511
bind $BINDIP
timeout 0
tcp-keepalive 300
supervised no
loglevel notice
databases 16
save 900 1
save 300 10
save 60 10000
protected-mode yes
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
requirepass $PASS
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-min-size 256mb
aof-load-truncated yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
unixsocket $SOCKET
unixsocketperm 700
rename-command FLUSHALL "mFLUSHALL"
rename-command FLUSHDB  "mFLUSHDB"
rename-command CONFIG   "mCONFIG"
rename-command KEYS     "mKEYS"
rename-command SHUTDOWN "mSHUTDOWN"
rename-command DEL "mDEL"
rename-command EVAL "mEVAL"
EOF
SERVER=`which redis-server`
su redis -c "$SERVER $CONFIG_DIR/'"$PORT"'.conf"
}


BINDIP=`ifconfig |grep -E -A 1  "eth0|lo"|grep inet|awk '{print $2}'|xargs`

DATADIR=/data/redis
CONFIG_DIR=/etc/redis
EX_PORT=17341
DB_VERSION=$1
EX_DIR=$DATADIR/$EX_PORT/

read -p "Please enter the number of instance you want to install: " N
N1=`expr $N - 1`

if [ -d $EX_DIR ]
	then
		PORT_ARRAY=(`ls $CONFIG_DIR|awk -F '.' '{print $1}'|xargs`)
		INIT_PORT=0
		for i in ${!PORT_ARRAY[*]}
			do
				echo $INIT_PORT
				if [ $INIT_PORT -le ${PORT_ARRAY[$i]} ]
					then INIT_PORT=${PORT_ARRAY[$i]}
				fi
			done

		MIN_PORT=`expr $INIT_PORT + 10`
		MAX_PORT=`expr $MIN_PORT + 10 \* $N1`
		
		for n in $(seq "$MIN_PORT" 10 "$MAX_PORT")
			do
				PORT=$n
				DIR=$DATADIR/$n/
				mkdir -p $DIR
				chown -R redis.redis $DIR
				LOGDIR=$DATADIR/log
				LOGFILE=$LOGDIR/redis_"$n".log
				PIDDIR=$DATADIR/run
				PIDFILE=$PIDDIR/"$n".pid
                SOCKET=$PIDDIR/redis_"$n".sock
				
			        init_config_file	
			done
	else
		MIN_PORT=$EX_PORT
		MAX_PORT=`expr $MIN_PORT + 10 \* $N1`
		LOGDIR=$DATADIR/log
		PIDDIR=$DATADIR/run
                
		mkdir -p "$LOGDIR"
		mkdir -p "$PIDDIR"
		mkdir -p $CONFIG_DIR

		init_env
		package

		chown -R redis.redis  $DATADIR
		
		for n in $(seq "$MIN_PORT" 10 "$MAX_PORT")
			do
				PORT=$n
				DIR=$DATADIR/$n/
				mkdir -p $DIR
				chown -R redis.redis $DIR
				LOGFILE=$LOGDIR/redis_"$n".log
				PIDFILE=$PIDDIR/"$n".pid
                SOCKET=$PIDDIR/redis_"$n".sock

				init_config_file
			done
fi
