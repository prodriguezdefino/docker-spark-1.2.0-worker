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

#set listener for sigterm an other signals in order to de-register from master node.
function cleanup {
	echo "cleaning stuff..."
	/etc/remote-remove-slave.sh $MASTER_NODE $IP
	echo "done!"
}
trap cleanup SIGTERM TERM 15

## configure the hadoop and spark installations
echo " "
echo "Preparing Apache Spark..."
echo " "
sed s/HOSTNAME/$MASTER_NODE/ $HADOOP_PREFIX/etc/hadoop/core-site.xml.template > $HADOOP_PREFIX/etc/hadoop/core-site.xml
sed "s/__MASTER__/$MASTER_NODE/;s/__HOSTNAME__/$HOSTNAME/;s/__LOCAL_IP__/$IP/" /tmp/spark-files/spark-env.sh.template > $SPARK_HOME/conf/spark-env.sh
sed s/HOSTNAME/$MASTER_NODE/ $SPARK_HOME/yarn-remote-client/core-site.xml.template > $SPARK_HOME/yarn-remote-client/core-site.xml
sed s/HOSTNAME/$MASTER_NODE/ $SPARK_HOME/yarn-remote-client/yarn-site.xml.template > $SPARK_HOME/yarn-remote-client/yarn-site.xml

echo " "
echo "Adding itself as a slave in Hadoop..."
echo " "
/etc/remote-add-slave.sh $MASTER_NODE $IP $HOSTNAME

echo " "
echo "Starting ssh service..."
echo " "
service ssh start

echo " "
echo "Starting Hadoop Datanode..."
echo " "
$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
sleep 5

echo " "
echo "Starting Spark Worker..."
echo " "
. $SPARK_HOME/conf/spark-env.sh
$SPARK_HOME/bin/spark-class org.apache.spark.deploy.worker.Worker $MASTER &

if [[ $2 == "-d" ]]; then
	wait
fi

if [[ $2 == "-bash" ]]; then
  /bin/bash
fi
