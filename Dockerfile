# Spark Master
FROM prodriguezdefino/spark-1.2.0-base:latest
MAINTAINER prodriguezdefino prodriguezdefino@gmail.com

# Expose TCP ports 7077 8080
EXPOSE 7077 8080
#ADD files /root/spark_master_files
#CMD ["/root/spark_master_files/default_cmd"]
