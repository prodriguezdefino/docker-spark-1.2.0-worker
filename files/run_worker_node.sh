#!/bin/bash
#

MASTER_NODE=$1

echo " "
echo " "
echo "****************************"
echo "* Apache Spark Worker Node *"
echo "****************************"
echo " "

echo " "
echo "Environment Variables: "
echo " "
env

IP=$(ip -o -4 addr list eth0 | perl -n -e 'if (m{inet\s([\d\.]+)\/\d+\s}xms) { print $1 }')
echo " "
echo "WORKER_IP=$IP"
echo " "

echo " "
echo "Preparing Apache Spark..."
echo " "
## configure the hadoop and spark installations
sed s/HOSTNAME/$MASTER_NODE/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml
sed -i s/__MASTER__/$MASTER_NODE/ /tmp/spark-files/spark-env.sh.template > $SPARK_HOME/conf/spark-env.sh

echo " "
echo "Adding itself as a slave in Hadoop..."
echo " "
/etc/remote-add-slave.sh $MASTER_NODE $IP

echo " "
echo "Starting ssh service..."
echo " "
service ssh start
sleep 2

echo " "
echo "Starting Hadoop Datanode..."
echo " "
$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode

echo " "
echo "Starting Spark Worker..."
echo " "
. $SPARK_HOME/bin/conf/spark-env.sh
$SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker $MASTER_NODE

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi