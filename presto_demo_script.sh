#!/bin/bash
PRESTO_VERSION=0.186
KAFKA_VERSION=0.10.2.1
CASSANDRA_VERSION=3.11.1
wget https://repo1.maven.org/maven2/com/facebook/presto/presto-server/$PRESTO_VERSION/presto-server-$PRESTO_VERSION.tar.gz
wget http://apache.rediris.es/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz 
wget http://apache.rediris.es/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz
wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$PRESTO_VERSION/presto-cli-$PRESTO_VERSION-executable.jar
tar -xvf presto-server-$PRESTO_VERSION.tar.gz; mv presto-server-$PRESTO_VERSION presto
tar -xvf apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz; mv apache-cassandra-$CASSANDRA_VERSION cassandra
tar -xvf kafka_2.11-$KAFKA_VERSION.tgz; mv kafka_2.11-$KAFKA_VERSION kafka
mv presto-cli-0.186-executable.jar presto-cli; chmod +x presto-cli
git clone https://github.com/big-data-europe/docker-hive.git
mkdir data-generator/kafka/generatorToKafka
git clone git@github.com:acesinc/json-data-generator.git data-generator/kafka
rm -rf *.tar.gz
rm -rf *.tgz
