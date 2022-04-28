# EMR-Observability

Amazon EMR is a cloud big data platform for running large-scale distributed data processing jobs, interactive SQL queries, and machine learning (ML) applications using open-source analytics frameworks such as Apache Spark, Apache Hive, Apache Hbase and Presto. Although EMR cluster has out of the box integration with Amazon Cloudwatch and Ganglia, there are below two primary challenges:
1. Amazon cloudwatch only covers cluster level metrics and does not provide granular metrics which are often required to stabilize and optimize any production clusters
2. Ganglia is available only during the duration of EMR cluster and metrics are lost once cluster is terminated. 

This article attempts to address above challenges by leveraging Amazon Managed Prometheus and Amazon Managed Grafana to store and visualize fine grained metrics from Amazon EMR cluster. The solution is resiliant to cluster termination ie., metrics are safely stored and available even if EMR cluster is shut down. This also gives you the ability to monitor multiple EMR clusters from a single place.  

With Amazon Managed Service for Prometheus, you use the same open-source Prometheus data model and PromQL query language that you use with Prometheus. Metrics ingested into a workspace are stored for 150 days, and are then automatically deleted. You incur charges for ingestion and storage of metrics. For more information, see [Pricing Details](https://aws.amazon.com/prometheus/pricing/). 

Amazon Managed Grafana is a fully managed service for open source Grafana developed in collaboration with Grafana Labs. Grafana is a popular open source analytics platform that enables you to query, visualize, alert on and understand your metrics no matter where they are stored. Check [Amazon Managed Grafana pricing](https://aws.amazon.com/grafana/pricing/) for more details. 

We will cover set up following EMR applications:
1. [Hbase](https://github.com/Anubhav02/EMR-Observability/tree/main/hbase_monitoring)
2. [Spark batch and streaming](https://github.com/Anubhav02/EMR-Observability/tree/main/spark_monitoring)



### Considerations and Limitations
1. These scripts are for training purpose only and not ready for production deployments. Please perform thorough testing. 
2. They have been tested on latest EMR version 6.4.0. 
3. You can set up alerting as well on Amazon Managed Prometheus. Refer [this] (https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-alert-manager.html) 
4. You can extend this solution to achieve presto metrics as well. 





