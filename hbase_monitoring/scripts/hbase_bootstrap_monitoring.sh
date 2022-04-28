#!/bin/bash -xe

#set up node_exporter for pushing OS level metrics
sudo useradd --no-create-home --shell /bin/false node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.0.0/node_exporter-1.0.0.linux-amd64.tar.gz
tar -xvzf node_exporter-1.0.0.linux-amd64.tar.gz
cd node_exporter-1.0.0.linux-amd64
sudo cp node_exporter /usr/local/bin/
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

cd /tmp
wget https://raw.githubusercontent.com/Anubhav02/EMR-Observability/main/hbase_monitoring/resources/node_exporter.service 
sudo cp node_exporter.service /etc/systemd/system/node_exporter.service
sudo chown node_exporter:node_exporter /etc/systemd/system/node_exporter.service
sudo systemctl daemon-reload && \
sudo systemctl start node_exporter && \
sudo systemctl status node_exporter && \
sudo systemctl enable node_exporter

#set up jmx_exporter for pushing application metrics
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.13.0/jmx_prometheus_javaagent-0.13.0.jar
sudo mkdir /etc/prometheus
sudo cp jmx_prometheus_javaagent-0.13.0.jar /etc/prometheus

wget https://raw.githubusercontent.com/Anubhav02/EMR-Observability/main/hbase_monitoring/jmx_yaml/hdfs_jmx_config_namenode.yaml
wget https://raw.githubusercontent.com/Anubhav02/EMR-Observability/main/hbase_monitoring/jmx_yaml/hdfs_jmx_config_datanode.yaml
wget https://raw.githubusercontent.com/Anubhav02/EMR-Observability/main/hbase_monitoring/jmx_yaml/hbase_jmx_config.yaml

HADOOP_CONF='/etc/hadoop/conf.empty'
sudo mkdir -p ${HADOOP_CONF}
sudo cp hdfs_jmx_config_namenode.yaml ${HADOOP_CONF}
sudo cp hdfs_jmx_config_datanode.yaml ${HADOOP_CONF}
sudo cp hbase_jmx_config.yaml ${HADOOP_CONF}


exit 0
