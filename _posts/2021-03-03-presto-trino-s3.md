---
title: "Querying S3 Object Stores with Presto or Trino"
category: blog
comments: True
featured: True
image: /assets/presto_trino_s3_files/CERN_Control_Center.jpg
imagesource: Wikimedia Commons
imageurl: https://commons.wikimedia.org/wiki/File:CERN_Control_Center.jpg
layout: post
tags: ['Presto', 'Trino', 'Data Engineering', 'Big Data', 'Hive', 'S3', 'Minio']
---
Querying big data on Hadoop can be challenging to get running, but alternatively, many solutions are using S3 object stores which you can access and query with Presto or Trino. In this guide you will see how to install, configure, and run Presto or Trino on Debian or Ubuntu with the S3 object store of your choice and the Hive standalone metastore.

This guide was tested on [MinIO](https://min.io/), [Linode object storage](https://www.linode.com/products/object-storage/), and [AWS S3](https://aws.amazon.com/s3/), with a personal preference for [Linode](https://www.linode.com/?r=e54e6c8185f5399de2527f9f3bc7cde39bbcc624). For installing Trino or Presto I recommend [Hetzner](https://hetzner.cloud/?ref=FkpdQcqbGXhP) VPS instances. To run the queries yourself, you can check out this [repository](https://github.com/njanakiev/trino-minio-docker) to help you replicate this guide locally with MinIO and docker. If you want to run Presto or Trino on Hadoop HDFS, have a look at this [tutorial](https://janakiev.com/blog/presto-cluster/).

# S3 Object Stores

Amazon started [AWS Simple Storage Service (S3)](https://aws.amazon.com/s3/) in 2006 and it is the most popular [object storage](https://en.wikipedia.org/wiki/Object_storage) to date. In S3 your data is grouped in buckets with a globally unique name and the data can be stored unstructured without a schema. It offers high scalability, high availability, and low latency storage and it is a common alternative to using HDFS and the [Hadoop](https://hadoop.apache.org/) ecosystem. Although S3 is no official standard, many vendors and projects support the interface and are compatible with S3. Depending on your needs and applications, there is a variety of possible S3 compatible object stores to choose from:

- [MinIO](https://min.io/)
- [Ceph](https://ceph.io/)
- [AWS S3](https://aws.amazon.com/s3/)
- [Linode Object Storage](https://www.linode.com/products/object-storage/)
- [Azure Blob Storage](https://azure.microsoft.com/en-us/services/storage/blobs/)
- [Google Cloud Storage](https://cloud.google.com/storage)

## Interacting with S3 Buckets using s3cmd

In order to interact with your S3 bucket, you need some tool. Many vendors have their own CLI tooling like the [AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/s3/) or [Linode CLI](https://www.linode.com/docs/guides/linode-cli/). A platform independent tool is [s3cmd](https://s3tools.org/s3cmd) which we will be using here. You can install s3cmd on Ubuntu/Debian with:

```bash
sudo apt update
sudo apt install s3cmd
```

Now, you need to configure the s3cmd environment with:

```bash
s3cmd --configure
```

After following all prompts, you can find the configuration in `~/.s3cfg`. If you want to save it as a custom profile you can add the `-c`/`--config` argument with the location of the configuration:

```bash
s3cmd --config aws.s3cfg --configure
```

__Warning: the access keys are saved in plain text__. Here is a list of useful commands when working with `s3cmd`:

- `s3cmd mb s3://bucket` Make bucket
- `s3cmd rb s3://bucket` Remove bucket
- `s3cmd ls` List available buckets
- `s3cmd ls s3://bucket` List folders within bucket
- `s3cmd get s3://bucket/file.txt` Download file from bucket
- `s3cmd get -r s3://bucket/folder` Download recursively files from bucket/directory
- `s3cmd put file.txt s3://bucket` Upload files to bucket
- `s3cmd put -r folder s3://bucket` Upload folder to bucket
- `s3cmd del s3://bucket/file.txt` Delete file or folder from bucket

For more commands and documentation, have a look at the [s3cmd usage](https://s3tools.org/usage).

# Hive Standalone Metastore

In any database, you need a place to manage the various tables, schemas, relationships, and views. This is commonly done in a metastore. When using S3 it is common to have the tables stored as CSV, [Apache Parquet](https://parquet.apache.org/), and [Apache ORC](https://orc.apache.org/) files among others. To store the schemas of those tables Trino/Presto needs [Apache Hive](https://hive.apache.org/) for the query engine to access the metadata of those tables. Hive is also commonly used as a metastore in the Hadoop ecosystem in projects like Apache Impala, Apache Spark, and Apache Drill.

## Installation

In my [previous tutorial](https://janakiev.com/blog/presto-cluster/), the installation relied on Hadoop and HDFS, but in this case, it will use a standalone version of the Hive metastore which runs without the rest of Hive. Hive metastore requires a database to store the schemas. For this, you can use DerbyDB, MySQL, MariaDB, and PostgreSQL. In this tutorial, you will see how to use it with MariaDB. Further, the metastore and Trino/Presto require Java 11. To install MariaDB and the Java 11 JRE, type:

```bash
sudo apt update
sudo apt install -y \
    mariadb openjdk-11-jre-headless
```

Now make sure it's enabled and running by typing:

```bash
sudo systemctl enable mariadb.service
sudo systemctl start mariadb.service
```

To check its status, you can type `systemctl status mariadb.service`. Next, you will need to create a user and a database for the Hive metastore, which you can do with the following command:

```bash
sudo mysql -u root -e "
    DROP DATABASE IF EXISTS metastore;
    CREATE DATABASE metastore;

    CREATE USER 'hive'@localhost IDENTIFIED BY 'hive';
    GRANT ALL PRIVILEGES ON *.* TO 'hive'@'localhost';
    FLUSH PRIVILEGES;"
```

Great, now that the database is set up, we can continue with downloading and extracting the metastore to `/usr/local/metastore` with:

```bash
wget "https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/3.1.2/hive-standalone-metastore-3.1.2-bin.tar.gz"
tar -zxvf hive-standalone-metastore-3.1.2-bin.tar.gz
sudo mv apache-hive-metastore-3.1.2-bin /usr/local/metastore
sudo chown user:user /usr/local/metastore
```

If you want to use another version instead of version `3.1.2` have a look at the following [list](https://repo1.maven.org/maven2/org/apache/hive/hive-standalone-metastore/). Hive metastore requires some dependencies from Hadoop, therefore you need to download Hadoop as well with:

```bash
wget "https://downloads.apache.org/hadoop/common/hadoop-3.2.1/hadoop-3.2.1.tar.gz"
tar xvf hadoop-3.2.1.tar.gz
sudo mv hadoop-3.2.1 /usr/local/hadoop
sudo chown user:user /usr/local/hadoop
```

There are a few dependencies that you need to copy and change to make it compatible with S3 and Hadoop. Here are the commands for that:

```bash
rm /usr/local/metastore/lib/guava-19.0.jar
cp /usr/local/hadoop/share/hadoop/common/lib/guava-27.0-jre.jar \
  /usr/local/metastore/lib/
cp /usr/local/hadoop/share/hadoop/tools/lib/hadoop-aws-3.2.1.jar \
  /usr/local/metastore/lib/
cp /usr/local/hadoop/share/hadoop/tools/lib/aws-java-sdk-bundle-1.11.375.jar \
  /usr/local/metastore/lib/
```

## Configuration

Now, Hive needs connection details to your S3 bucket. This can be done in the `/usr/local/metastore/conf/metastore-site.xml` file. Open the existing `metastore-site.xml` and add the following properties within the `<configuration>` section:

```xml
<property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://localhost/metastore?createDatabaseIfNotExist=true</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>hive</value>
</property>
<property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>hive</value>
</property>
<property>
    <name>hive.metastore.event.db.notification.api.auth</name>
    <value>false</value>
</property>
```

Further, add those properties to specify the S3 connection:

```xml
<property>
    <name>fs.s3a.access.key</name>
    <value>S3_ACCESS_KEY</value>
</property>
<property>
    <name>fs.s3a.secret.key</name>
    <value>S3_SECRET_KEY</value>
</property>
<property>
    <name>fs.s3a.connection.ssl.enabled</name>
    <value>false</value>
</property>
<property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
</property>
<property>
    <name>fs.s3a.endpoint</name>
    <value>S3_ENDPOINT</value>
</property>
```

Additionally, you will need to define the `JAVA_HOME` and `HADOOP_HOME` environment variables, which you can set with:

```bash
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop
```

To have those ready every time you open the shell, you need to append those two lines in the `~/.bashrc` file. Once you have everything configured, you can initialize the metastore with:

```bash
/usr/local/metastore/bin/schematool -initSchema -dbType mysql
```

After the initialization is finished, you can start the metastore service with:

```bash
/usr/local/metastore/bin/start-metastore &
```

For more information about the metastore configuration, have a look at the [documentation](https://cwiki.apache.org/confluence/display/Hive/AdminManual+Metastore+3.0+Administration) and  more specifically on [Running the Metastore Without Hive](https://cwiki.apache.org/confluence/display/Hive/AdminManual+Metastore+3.0+Administration#AdminManualMetastore3.0Administration-RunningtheMetastoreWithoutHive).

# Trino and Presto

[Trino](https://trino.io/) and [Presto](https://prestodb.io/) are both open-source distributed query engines for big data across a large variety of data sources including HDFS, S3, PostgreSQL, MySQL, Cassandra, MongoDB, and Elasticsearch among others. To see the difference between both projects, have a look at this [article](https://trino.io/blog/2020/12/27/announcing-trino.html). In this installation, you will see how to install Trino 352 in particular, but all the steps and queries were also tested on Presto 0.247.

## Installation

After you have S3 and the Hive standalone metastore ready, you can proceed with installing and configuring Trino on your server. To install it, download it from [here](https://trino.io/download.html) and extract it in `/usr/local/trino` as outlined here:

```bash
wget "https://repo1.maven.org/maven2/io/trino/trino-server/352/trino-server-352.tar.gz"
tar -xzvf trino-server-352.tar.gz
sudo mv trino-server-352 /usr/local/trino
sudo chown $$USER:$$USER /usr/local/trino
```

Additionally, you will need the CLI in order to access the query engine, which you can download to the `bin` folder of the same directory and make it executable:

```bash
wget "https://repo1.maven.org/maven2/io/trino/trino-cli/352/trino-cli-352-executable.jar"
mv trino-cli-352-executable.jar /usr/local/trino/bin/trino
sudo chmod +x /usr/local/trino/bin/trino
```

## Configuration

Lastly, you need to configure Trino. For this, you have a few configuration files that are required. First you need the configuration for the JVM in `/usr/local/trino/etc/jvm.config`. You can fill it with the following contents:

```
-server
-Xmx6G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:+ExitOnOutOfMemoryError
-Djdk.attach.allowAttachSelf=true
```

Here, make sure that you utilize your RAM memory properly by specifying `-Xmx` with around 80% of your available memory. This way you will have enough memory for the system as long as you don't have anything else running on this machine. In this example, it is set to 6 GB. Next up, is the `/usr/local/trino/etc/node.properties` which contains configuration for each node:

```
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/usr/local/trino/data
```

Here you need to specify the name of the environment with `node.environment`, the unique identifier of the node with `node.id`, and finally the directory of the data directory with `node.data-dir`. Nest, you need to add the configuration for the Trino server in `/usr/local/trino/etc/config.properties`. Here is a possible configuration:

```
coordinator=true
node-scheduler.include-coordinator=true
http-server.http.port=8080
query.max-memory=50GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
discovery-server.enabled=true
discovery.uri=http://localhost:8080
```

The configuration of how much memory requires some trial and error and depends on the expected workload and the number of queries that will run simultaneously. A good tutorial on the topic that you can follow is [Memory Configuration in Presto Cluster](https://techjogging.com/memory-setup-prestodb-cluster.html). Finally, you need to configure the connection to S3. For this create the file `/usr/local/trino/etc/catalog/hive.properties` with the following contents:

```
connector.name=hive-hadoop2
hive.metastore.uri=thrift://localhost:9083
hive.s3.path-style-access=true
hive.s3.endpoint=S3_ENDPOINT
hive.s3.aws-access-key=S3_ACCESS_KEY
hive.s3.aws-secret-key=S3_SECRET_KEY
hive.s3.ssl.enabled=false
```

This should do the trick. For more information on the deployment and the Hive connector have a look at [Deploying Trino](https://trino.io/docs/current/installation/deployment.html), the [Hive connector](https://trino.io/docs/current/connector/hive.html) documentation, and the [Hive connector with Amazon S3](https://trino.io/docs/current/connector/hive-s3.html) documentation. For multi-node configuration, follow this [tutorial](https://janakiev.com/blog/presto-cluster/).

Now, you should be able to start Trino by running:

```bash
/usr/local/trino/bin/launcher start
```

Once it is running, you should open the Trino web UI at `localhost:8080` with the port previously defined in `config.properties`. Once you run queries, they should be listed there.

## Query Data stored on S3

We will work with a previously uploaded parquet file which you can find in this [repository](https://github.com/njanakiev/trino-minio-docker), which was converted from the famous [Iris data set](https://archive.ics.uci.edu/ml/datasets/iris). In this example the file is stored on the bucket at `s3a://iris/iris_parquet/iris.parq`. First, you need to create a schema to access the file which you can do by running the following SQL statement:

```sql
CREATE SCHEMA IF NOT EXISTS hive.iris
WITH (location = 's3a://iris/');
```

Next, you need to create a table to the existing data set on S3 with:

```sql
CREATE TABLE IF NOT EXISTS hive.iris.iris_parquet (
  sepal_length DOUBLE,
  sepal_width  DOUBLE,
  petal_length DOUBLE,
  petal_width  DOUBLE,
  class        VARCHAR
)
WITH (
  external_location = 's3a://iris/iris_parquet',
  format = 'PARQUET'
);
```

Now, you should be able to query the data with:

```sql
SELECT 
  sepal_length,
  class
FROM hive.iris.iris_parquet 
LIMIT 10;
```

To show all tables in a particular schema, you can type `SHOW TABLES IN hive.iris;`.

# Conclusion

There you have it. You have seen how to setup Trino or Presto to query data stored on S3 storage like AWS S3, Linode object storage, or MinIO among others. If you are already familiar with S3, this makes it incredibly easy to query large data sets instead of dealing with preparing HDFS on local infrastructure. Trino and Presto provide separation of data and compute which makes it a one-stop-shop to query across multiple data sources with their federated queries in reasonable time and low technical overhead. For more useful information, have a look at the following resources:

## Resources

- Github - [s3tools/s3cmd](https://github.com/s3tools/s3cmd) Command line tool for managing Amazon S3 and CloudFront services
- Github - [njanakiev/trino-minio-docker](https://github.com/njanakiev/trino-minio-docker) Minimal example to run Trino, Minio, and Hive standalone metastore on docker
- Github - [starburstdata/presto-minio](https://github.com/starburstdata/presto-minio) Presto and Minio on Docker Infrastructure
- 2020 - [A gentle introduction to the Hive connector](https://trino.io/blog/2020/10/20/intro-to-hive-connector.html)
- 2020 - [Memory Configuration in Presto Cluster](https://techjogging.com/memory-setup-prestodb-cluster.html)
- 2019 - [Running Presto on MinIO: Benchmarking vs. AWS S3](https://blog.min.io/running-presto-on-minio-benchmarking-vs-aws-s3/)
- 2018 - [Interactive SQL query with Presto on MinIO Cloud Storage](https://blog.min.io/interactive-sql-query-with-presto-on-minio-cloud-storage/)
- [How to Use Linode Object Storage](https://www.linode.com/docs/guides/how-to-use-object-storage/)

There were also some related podcasts in this topic by the [Data Engineering Podcast](https://www.dataengineeringpodcast.com), which were worth a listen:

- 2020 - [Behind The Scenes Of The Linode Object Storage Service](https://www.dataengineeringpodcast.com/linode-object-storage-service-episode-125/)
- 2020 - [Simplify Your Data Architecture With The Presto Distributed SQL Engine](https://www.dataengineeringpodcast.com/presto-distributed-sql-episode-149/)

## Appendix

Running the Hive metastore can be tiresome and for quick tests it can be sometimes useful to use the build-in FileHiveMetastore. Be warned, __It is not advised to use it in production__ and there are barely any documentation about it except for these articles and discussions:

- 2020 - [Access MinIO S3 Storage in Presto with File Metastore](https://techjogging.com/access-minio-s3-storage-prestodb-cluster.html)
- 2019 - [Building an on-premise ML ecosystem with MinIO Powered by Presto, R and S3 Select Feature](https://blog.min.io/building-an-on-premise-ml-ecosystem-with-minio-powered-by-presto-r-and-s3select-feature/)
- 2018 - [Setup Standalone Hive Metastore Service For Presto and AWS S3](https://stackoverflow.com/questions/48932907/setup-standalone-hive-metastore-service-for-presto-and-aws-s3)
- Github - [FileHiveMetastore example/documentation? #11943](https://github.com/prestodb/presto/issues/11943)