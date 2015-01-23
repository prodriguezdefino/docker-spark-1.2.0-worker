## Apache Spark Worker Node
#
FROM prodriguezdefino/spark-1.2.0-base:latest
MAINTAINER prodriguezdefino prodriguezdefino@gmail.com

# Instead of using a random port, bind the worker to a specific port
ENV SPARK_WORKER_PORT 8888
EXPOSE 8888

RUN mkdir $SPARK_HOME/spark_worker_files
ADD files $SPARK_HOME/spark_worker_files
RUN chmod 755 $SPARK_HOME/spark_worker_files/run_worker_node.sh

RUN rm -rf $SPARK_HOME/work
RUN mkdir -p $SPARK_HOME/work
#RUN chown hdfs.hdfs $SPARK_HOME/work
RUN rm -rf /tmp/spark
RUN mkdir /tmp/spark
#RUN chown hdfs.hdfs /tmp/spark

## this one is for Spark shell logging
RUN rm -rf /var/lib/hadoop/hdfs
RUN mkdir -p /var/lib/hadoop/hdfs
#RUN chown hdfs.hdfs /var/lib/hadoop/hdfs
RUN rm -rf $SPARK_HOME/logs
RUN mkdir -p $SPARK_HOME/logs
#RUN chown hdfs.hdfs /opt/spark-$SPARK_VERSION/logs

## deploy the master files
RUN cp /tmp/spark-files/log4j.properties $SPARK_HOME/conf/

CMD ["/usr/local/spark/spark_master_files/run_worker_node.sh", "master"]
