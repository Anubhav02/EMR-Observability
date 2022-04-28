# EMR-Observability

This section covers how you can leverage Amazon Managed Prometheus and Amazon Managed Grafana to store and visualize jmx metrics from Amazon EMR cluster.

With Amazon Managed Service for Prometheus, you use the same open-source Prometheus data model and PromQL query language that you use with Prometheus. Metrics ingested into a workspace are stored for 150 days, and are then automatically deleted. You incur charges for ingestion and storage of metrics. For more information, see [Pricing Details](https://aws.amazon.com/prometheus/pricing/). 

Amazon Managed Grafana is a fully managed service for open source Grafana developed in collaboration with Grafana Labs. Grafana is a popular open source analytics platform that enables you to query, visualize, alert on and understand your metrics no matter where they are stored. Check [Amazon Managed Grafana pricing](https://aws.amazon.com/grafana/pricing/) for more details. 

We will cover following EMR applications
1. [Hbase](https://github.com/Anubhav02/EMR-Observability/tree/main/hbase_monitoring)
2. [Spark batch and streaming](https://github.com/Anubhav02/EMR-Observability/tree/main/spark_monitoring)

You can also extend the same model to achieve presto metrics as well. 

### Considerations
1. These scripts are for training purpose only and not ready for production deployments. Please perform thorough testing. 
2. They have been tested on latest EMR version 6.4.0. 





