## Set-up for Spark enabled EMR clusters

#### Step:1 Clone the github or download the contents and upload all files to S3 bucket where you have read access. 
1. `git clone https://github.com/Anubhav02/EMR-Observability.git`
2.  Copy all json under spark_monitoring/cloudformation_template/ to S3 bucket

#### Step:2 Launch Cloudformation template with below changes 
1. Change `TemplateURl` value in `emr_cluster_prometheus_cf.json` to s3 https location of relevant nested stack location (IamForPrometheus.json and emr_cluster_prometheus.json)
![image](https://user-images.githubusercontent.com/8313805/165848849-0ad7f297-2e21-43b2-8214-f7ff48c6e3e7.png)

#### Step:3 Launch emr_cluster_prometheus_cf.json cloud formation template. Below values are required:
1.  Stack Name - EMRMonitoring             
2.  VPC - select appropriate VPC from dropdwn
3.  Subnet - Select apprpriate subnet from dropdown
4.  EMRClusterName - emrSpark
6.  EMRBootstrapDir - s3://emr_cluster/spark_bootstrap_monitoring.sh
7.  MasterInstanceType - Chose supported instance type from dropdown
8.  CoreInstanceType - Chose supported instance type from dropdown
9.  CoreInstanceCount - Default is 2
10. EMRSSHIPRange - `<your ip address>/32`
11. EMRKeyName - Select from dropdown to select existing keypairs 
12. EMRRleaseLabel - Chose release label from dropdown
13. InstanceType - Instance type for installing prometheus server. Select from dropdown
14. SSHIPRange - `<your ip address>/32`
15. PrometheusIPRange - `<your ip address>/32`

#### Step:4 Create workspace in Amazon Managed Prometheus 
1. Go to AWS console and search for Amazon Managed Prometheus
2. Click `create` to create a workspace and copy 'Endpoint - remote write URL'
3. Ssh into ec2 instance where prometheus server is running(You can find instance id in cloudformation stack under Resources tab against PrometheusServerInstance). Copy prometheus endpoint 'Endpoint - remote write URL' from AMP console and edit `remote_write url` in `/etc/prometheus/conf/prometheus.yaml`. 

```
ssh -i <sshKey.pem> ec2-user@<Public IPv4 DNS>
#edit below file
sudo vi /etc/prometheus/conf/prometheus.yaml
#Restart prometheus server
sudo systemctl restart prometheus
```

Note: You do not need to create a new workspace if you already have one created.

#### Step:5 Create workspace in Amazon Managed Grafana 
1. Log on to AWS console for Amazon Managed Grafana and hit create workspace
2. Chose AWS Single Sign-on as authentication method. 
3. Chose Amazon Managed Service for Prometheus in Data Sources. Aditionally for notification can chose Amazon SNS. 
4. Once workspace creation is finished, you will need to assign a new user or group. You can select any existing AWS SSO use/group or create new. Make sure User Type is Admin
5. Once authentication is set, click on Grafana workspace URL and log in using AWS SSO crdentials. 
6. Once inside Grafana console, select `AWS Data Sources` from left panel, add `Amazon Managed for Prometheus` and appropriate region.   

Note: You do not need to create a new workspace if you already have one created.

#### Step:6 Run a sample job
1. First, lets change /etc/spark/conf/metrics.properties file on master node to emit spark jmx metrics. Uncomment following line `*.sink.jmx.class=org.apache.spark.metrics.sink.JmxSink` in the file
2. Run below sample job 

```
spark-submit --master yarn --deploy-mode cluster \
--conf spark.metrics.namespace=spark --conf spark.metrics.appStatusSource.enabled=true \
--conf "spark.driver.extraJavaOptions=-javaagent:/etc/prometheus/jmx_prometheus_javaagent-0.13.0.jar=7006:/etc/hadoop/conf/spark_jmx_config.yaml" \
--conf "spark.executor.extraJavaOptions=-javaagent:/etc/prometheus/jmx_prometheus_javaagent-0.13.0.jar=7007:/etc/hadoop/conf/spark_jmx_config.yaml" \
--class org.apache.spark.examples.SparkPi /usr/lib/spark/examples/jars/spark-examples.jar 10000
```

#### Step:6 Create graphs on important metrics
1. For detailed set of spark metrics that you can plot on Amazon Managed Grafana refer [this](https://spark.apache.org/docs/latest/monitoring.html#metrics)
2. Spark-3 has [executor metris](https://spark.apache.org/docs/latest/monitoring.html#executor-metrics) , which can help you answer how much memory you need for your spark executors. For example, in above spark pi job, see blow executorJVM memory chart

![image](https://user-images.githubusercontent.com/8313805/165838367-e53e1319-0100-4f96-8cef-33998ffa8afb.png)

This shows peak executor memory used is around 763MiB by executor_id=1, however the executor memory allocated from spark conf - spark.executor.memory=10G. It clearly indicates almost 1% of allocated memory is used and 99% is wasted. 


### Considerations
1. Metrics are avilable for multiple clusters, so you will need to add label for appropriate cluster_id
2. In absence of namespace(spark.metrics.namespace), by default driver and executor metrics take application ID as root namespace. However, often times, users want to be able to track the metrics across apps for driver and executors, which is hard to do with application ID (i.e. spark.app.id) since it changes with every invocation of the app. For such use cases, a custom namespace can be specified for metrics reporting using spark.metrics.namespace configuration property.
3. For monitoring spark structured streaming, set spark.sql.streaming.metricsEnabled=true(default is false).
4. Detailed metrics for Hadoop Namenode, Datanode, Yarn Resource manager and Node manager are also collected. You can set up appropriate charts to visualize those if needed. 


