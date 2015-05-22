## Apache Spark Worker Node
#
FROM prodriguezdefino/sparkbase
MAINTAINER prodriguezdefino prodriguezdefino@gmail.com

# Instead of using a random port, bind the worker to a specific port
ENV SPARK_WORKER_PORT 8888
EXPOSE 8888
# In case of need we expose the shell node for later monitoring through the spark context published web page 
ENV SPARK_SHELL_PORT 4040
EXPOSE 4040


RUN mkdir $SPARK_HOME/spark_worker_files
ADD files $SPARK_HOME/spark_worker_files
RUN chmod 755 $SPARK_HOME/spark_worker_files/run_worker_node.sh

RUN rm -rf $SPARK_HOME/work
RUN mkdir -p $SPARK_HOME/work
RUN rm -rf /tmp/spark
RUN mkdir /tmp/spark
RUN rm -rf /tmp/hadoop-root
RUN mkdir /tmp/hadoop-root

## this one is for Spark shell logging
RUN rm -rf /var/lib/hadoop/hdfs
RUN mkdir -p /var/lib/hadoop/hdfs
RUN rm -rf $SPARK_HOME/logs
RUN mkdir -p $SPARK_HOME/logs

## deploy the master files
RUN cp /tmp/spark-files/log4j.properties $SPARK_HOME/conf/

CMD ["/usr/local/spark/spark_worker_files/run_worker_node.sh", "master.sparkmaster.dev.docker", "-d"]
