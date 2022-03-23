#!/bin/bash
PATH=$PATH:$HOME/bin

##DBFILE##
echo "## Enter DB Binary File  Ex) mariadb-10.2.12-linux-x86_64##"
read DBFILE

INSTALL=/root/$DBFILE.tar.gz

echo "## Enter DIR Ex)data -> /data/data /data/log /data/maria##"
read DIR

##MV DBFILE##
a=`find / -name "${DBFILE}*"`
echo $a
mv $a /root/

DATADIR=$DIR/data
LOGDIR=$DIR/log
BASEDIR=$DIR/maria

##CREATE DIRECTORY
groupadd mysql
useradd -g mysql mysql
mkdir -p $DATADIR
mkdir -p $LOGDIR
chown -R mysql.mysql $DIR


##UNZIP
tar -zxvf $INSTALL -C $DIR
mv $DIR/$DBFILE $BASEDIR


##MY.CNF
buffer_pool=`free -b | grep Mem | awk '{print $2}'`
buffer_pool=$(($buffer_pool/2))


cat > /etc/my.cnf <<EOF
[mysqld]
datadir=$DATADIR
socket=/tmp/mysql.sock
log-error=$LOGDIR/mariadb.log
pid-file=$LOGDIR/mariadb.pid
symbolic-links=0
innodb_buffer_pool_size=$buffer_pool


[mysqld_safe]
log-error=$LOGDIR/mariadb.log
pid-file=$LOGDIR/mariadb.pid


!includedir /etc/my.cnf.d
EOF


##INSTALL
$BASEDIR/scripts/mysql_install_db --user=mysql --basedir=$BASEDIR


##BASH
bash=`cat ~/.bash_profile | grep PATH | grep -v export`


bash2=$bash:/data/maria/bin
echo $bash2$'\n'"export PATH " >> /root/.bash_profile


source /root/.bash_profile


##START
mysqld_safe --user=mysql &


##CHANGE ROOT
mysql -uroot -p -e "alter user 'root'@'localhost' identified by 'root'"
