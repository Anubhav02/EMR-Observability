## Set-up for Hbase enabled EMR clusters

#### Step:1 Clone the github or download the contents and upload all files to S3 bucket where you have read access. 
1. `git clone https://github.com/Anubhav02/EMR-Observability.git`
2.  Copy all json under hbase_monitoring/cloudformation_template/ to S3 bucket

#### Step:2 Launch Cloudformation template with below changes 
1. Change `TemplateURl` value in `emr_cluster_prometheus_cf.json` to s3 https location of relevant nested stack location (IamForPrometheus.json and emr_cluster_prometheus.json)
![image](https://user-images.githubusercontent.com/8313805/165848849-0ad7f297-2e21-43b2-8214-f7ff48c6e3e7.png)


#### Step:3 Launch emr_cluster_prometheus_cf.json cloud formation template. Below values are required:
1.  Stack Name - EMRMonitoring             
2.  VPC - select appropriate VPC from dropdwn
3.  Subnet - Select apprpriate subnet from dropdown
4.  EMRClusterName - emrHbase
5.  HbaseRootDir - s3://emr_cluster/myhabserootdir
6.  EMRBootstrapDir - s3://emr_cluster/hbase_bootstrap_monitoring.sh
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
7. Now lets create a dashboard. Hover on `+` symbol on left panel and chose import. Grafana labs has few open source pre built dashboards to chose from. You can chose https://grafana.com/grafana/dashboards/12722 and hit Load. 
8. You should see all hbase revelant metrics start to come up on the dashboard. 

Note: You do not need to create a new workspace if you already have one created.

![image](https://user-images.githubusercontent.com/8313805/165374600-eb6615f6-38d1-4638-b528-1a1c88c17b42.png)

### Considerations
1. Hadoop Namenode and Datanode jmx metrics are also collected along with Hbase. You can set up charts for them as well if needed. 
