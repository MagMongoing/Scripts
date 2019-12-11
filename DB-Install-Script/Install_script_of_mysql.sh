

function init_env()
{
    yum -y install libaio numactl.x86_64
    groupadd mysql
    useradd -s /bin/false -r -g mysql  mysql
    cd /usr/local/src
    wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-$DB_VERSION-linux-glibc2.12-x86_64.tar.gz
    tar -xzf mysql-$DB_VERSION-linux-glibc2.12-x86_64.tar.gz -C ../
    cd /usr/local/
    chown -R mysql.mysql /usr/local/mysql-$DB_VERSION-linux-glibc2.12-x86_64 
    ln -s /usr/local/mysql-$DB_VERSION-linux-glibc2.12-x86_64 /usr/local/mysql
    echo 'PATH=$PATH:/usr/local/mysql/bin'>>/etc/profile
    source /etc/profile
    mkdir /data/tmp -p
    chown -R mysql.mysql /data/tmp
    chmod 750 /data/tmp
    cat /dev/null>/etc/my.cnf 
}


config_single(){
cat >/etc/my.cnf<<EOF
[client]
port = 3341
default-character-set = utf8mb4
socket = /tmp/mysql.sock

[mysql]
default-character-set = utf8mb4

[mysqld]
port = 3341
socket = /tmp/mysql.sock

#time
explicit_defaults_for_timestamp = true
log_timestamps = SYSTEM
#default-time-zone = "Asia/Shanghai"

basedir = $BASEDIR
datadir = $DATADIR
open_files_limit = 3072
back_log = 100
max_connections = 500
max_connect_errors = 100000
table_open_cache = 1024
external-locking = false
max_allowed_packet = 32M
sort_buffer_size = 1M
join_buffer_size = 1M
thread_cache_size = 51
#query_cache_size = 0
tmp_table_size = 96M
max_heap_table_size = 96M
slow_query_log = 1
slow_query_log_file = $DATADIR/slow.log
log_error = $DATADIR/mysql.err
long_query_time = 0.5
pid_file = $DATADIR/mysql.pid
key_buffer_size = 32M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
character-set-server = utf8mb4
default-storage-engine = InnoDB

# safety
symbolic-links = 0
tmpdir = $TMPDIR
secure_file_priv = $TMPDIR

# replication setting
server-id = $SID
binlog_format = row
binlog_row_image = full
log_bin = $DATADIR/mysql-bin
sync_binlog = 1
binlog_cache_size = 2M
max_binlog_cache_size = 64M
max_binlog_size = 1024M
expire_logs_days = 30
relay_log = $DATADIR/mysql-relay-bin
relay_log_recovery = 1
relay_log_info_repository = table
master_info_repository = table
slave_preserve_commit_order = 1

# GTID
gtid_mode = on
log_slave_updates = 1
enforce_gtid_consistency = 1

#sql_mode: NO_AUTO_CREATE_USER is depricated, it will be removed
sql_mode = NO_ENGINE_SUBSTITUTION

# innodb
transaction_isolation = REPEATABLE-READ
innodb_buffer_pool_size = $innodb_buffer_pool_size
innodb_data_home_dir = $DATADIR
innodb_data_file_path = ibdata1:1024M:autoextend
innodb_flush_log_at_trx_commit = 1
innodb_log_buffer_size = 16M
innodb_log_file_size = $innodb_log_file_size
innodb_log_files_in_group = 2
innodb_max_dirty_pages_pct = 50
innodb_file_per_table = 1
#innodb_file_format = Barracuda
innodb_locks_unsafe_for_binlog = 0
innodb_stats_include_delete_marked = 1

#timeout
interactive_timeout = 320
wait_timeout = 320

skip-name-resolve

[mysqldump]
quick
max_allowed_packet = 32M


EOF
}

config_multi(){
cat >>/etc/my.cnf <<EOF
[mysqld$port]
port = $port
socket = $sock

explicit_defaults_for_timestamp = true
log_timestamps = SYSTEM
#default-time-zone = "Asia/Shanghai"

basedir = $BASEDIR
datadir = $DATADIR
open_files_limit = 3072
back_log = 100
max_connections = 500
max_connect_errors = 100000
table_open_cache = 1024
external-locking = false
max_allowed_packet = 32M
sort_buffer_size = 1M
join_buffer_size = 1M
thread_cache_size = 51
#query_cache_size = 0
tmp_table_size = 96M
max_heap_table_size = 96M
slow_query_log = 1
slow_query_log_file = $DATADIR/slow.log
log_error = $DATADIR/mysql.err
long_query_time = 0.5
pid_file = $DATADIR/mysql.pid
key_buffer_size = 32M
read_buffer_size = 1M
read_rnd_buffer_size = 16M
bulk_insert_buffer_size = 64M
character-set-server = utf8mb4
default-storage-engine = InnoDB

# safety
symbolic-links = 0
tmpdir = /data/tmp
secure_file_priv = /data/tmp

# replication setting
server-id = $sid
log_bin = $DATADIR/mysql-bin
sync_binlog = 1
binlog_format = row
binlog_cache_size = 4M
max_binlog_cache_size = 128M
max_binlog_size = 1024M
expire_logs_days = 7
relay_log_info_repository = table
master_info_repository = table
relay_log = $DATADIR/mysql-relay-bin
relay_log_recovery = 1
slave_preserve_commit_order = 1

# GTID
gtid_mode=on
log_slave_updates = 1
enforce_gtid_consistency = 1
sql_mode = NO_ENGINE_SUBSTITUTION

# innodb
transaction_isolation = REPEATABLE-READ
innodb_buffer_pool_size = $innodb_buffer_pool_size
innodb_data_home_dir = $DATADIR
innodb_data_file_path = ibdata1:1024M:autoextend
innodb_flush_log_at_trx_commit = 1
innodb_log_buffer_size = 16M
innodb_log_file_size = $innodb_log_file_size
innodb_log_files_in_group = 2
innodb_max_dirty_pages_pct = 50
innodb_file_per_table = 1
#innodb_file_format = Barracuda
innodb_locks_unsafe_for_binlog = 0

innodb_stats_include_delete_marked = 1

#timeout
interactive_timeout = 320
wait_timeout = 320

skip-name-resolve
#slave-skip-errors = all
skip-slave-start

EOF
}

config_mult_end()
{
cat >>/etc/my.cnf<<EOF
[mysqldump]
quick
max_allowed_packet = 32M

[mysqld_multi]
mysqld = $BASEDIR/bin/mysqld_safe
mysqladmin = $BASEDIR/bin/mysqladmin
log = /data/mysql/mysqld_multi.log
EOF
}


read -p "Please enter the number of instance you want to install: " N

SID_PRE=`ifconfig|grep -E -A 1 "eth0"|grep inet|awk '{print $2}'|xargs| cut -d '.' -f 4`
MIN_SID="$SID_PRE"41
MAX_SID=`expr $MIN_SID + $N - 1 `


BASEDIR=/usr/local/mysql
TMPDIR=/data/tmp
innodb_buffer_pool_size=4096M
innodb_log_file_size=1024M
DB_VERSION=$1

init_env

if [ $N -eq 1 ]
	then
        DATADIR=/data/mysql
        mkdir -p $DATADIR
        rm -rf $DATADIR/*
        chown -R mysql.mysql $DATADIR
        chmod 750 $DATADIR
        SID=$MIN_SID
        config_single
        $BASEDIR/bin/mysqld --defaults-file=/etc/my.cnf --initialize --datadir=$DATADIR --basedir=$BASEDIR --user=mysql
        $BASEDIR/bin/mysqld_safe --defaults-file=/etc/my.cnf &
    else
        port=3340
        for sid in $(seq "$MIN_SID" "$MAX_SID")
            do
                port=`expr $port + 1`
                DATADIR=/data/mysql/$port
                sock=/tmp/mysql"$port".sock
                mkdir -p $DATADIR
                rm -rf $DATADIR/*
                chown -R mysql.mysql $DATADIR
                chmod 750 $DATADIR
                config_multi
            done
        config_mult_end
        port=3341
        max_port=`expr $port + $N - 1`
        for p in $(seq "$port" "$max_port")
            do
                $BASEDIR/bin/mysqld --defaults-file=/etc/my.cnf --initialize --datadir=/data/mysql/$p --basedir=$BASEDIR --innodb_data_file_path=ibdata1:1024M:autoextend  --log_error=/data/mysql/$p/mysql.err --user=mysql
                $BASEDIR/bin/mysqld_multi --defaults-file=/etc/my.cnf start $p
                sleep 20s
                PASS=`cat /data/mysql/$p/mysql.err |grep "A temporary password is generated for root@localhost:"|awk  '{print $11}'`
                echo $PASS
                read -s -p "PASS: " NEW_PASS
                $BASEDIR/bin/mysql -uroot -p$PASS -S /tmp/mysql$p.sock --connect-expired-password -e "alter user root@localhost identified by '$NEW_PASS';"
                sleep 5s
                echo ""
            done
fi





