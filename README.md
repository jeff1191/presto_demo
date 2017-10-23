## Presto Demo

### Requisitos
- Java 8
- docker/docker compose
- Maven
#### Configuración

1. `git clone https://github.com/jeff1191/presto_demo.git`

2. `chmod +x presto_demo_script.sh`

3. `./presto_demo_script.sh`

4. Ejecutando el script se crea la estructura con los siguientes directorios:

|Directorio | Descripción |  
|------------- |------------- |
|cassandra| cluster-cassandra| 
|kafka | cluster-kafka | 
|presto | cluster-presto |  
|docker-hive | docker que nos levanta hive además del namenode, datanode, hdfs, hive |
|etc | configuración del clúster de presto sobre cada uno de los sources | 
|json-data-generator | herramienta para generar eventos a kafka |
|data-generator | información que vamos a introducir en cassandra, hive y kafka | 

5. Descargar/iniciar el docker-hive, esto incluye el (namenode, datanode, hdfs)( Más información -> https://github.com/big-data-europe/docker-hive)

`cd docker-hive`

`docker-compose build`

`docker-compose up -d namenode hive-metastore-postgresql`

`docker-compose up -d datanode hive-metastore`

`docker-compose up -d hive-server`

Introducimos información a hive
 
`docker cp data-generator/hive/hive-data.csv  hive-server:/opt/hive-data.csv`

`docker exec -it hive-server bash`

`hadoop fs -mkdir /tmp/data`

`hadoop fs -put hive-data.csv /tmp/data`

`/opt/hive/bin/beeline -u jdbc:hive2://localhost:10000`

```
CREATE EXTERNAL TABLE users
(id INT,first_name STRING,email STRING,gender STRING,MAC,address STRING,phone STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tmp/data';
```
6. Creamos keyspace/table en Cassandra e importamos información. Desde la carpeta presto_demo, nos metemos en el directorio de cassandra/bin
 
 `./cassandra -f -R`
 
 `./cqlsh`
 
 `SELECT * FROM system_schema.keyspaces;`
 
 ```
 CREATE KEYSPACE apps WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '1'}  AND durable_writes = true;
``` 
  ```
CREATE TABLE apps.conn( id int, appName text,phone text,timestmp timestamp);  
   ```
  ```
 COPY apps.conn [id,appName,phone,timestmp] FROM '../../data-generator/cassandra/cassandra-data.csv'
 ```
7. Iniciamos zookeeper/kafka y creamos topic

`kafka/bin/zookeeper-server-start.sh -daemon kafka/config/zookeeper.properties`

`kafka/bin/kafka-server-start.sh -daemon kafka/config/server.properties`

`kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic demo.events`

8. Configuración para simular eventos en tiempo real a kafka( Más información -> https://github.com/acesinc/json-data-generator)

`cd json-data-generator`

`mvn clean package`

`cp target/json-data-generator-1.0.0-bin.tar ../data-generator/kafka`

`cd ../data-generator/kafka`

`tar xvf json-data-generator-1.0.0-bin.tar`

`mv *.json json-data-generator`

`cd json-data-generator`

Para simular los eventos en tiempo real: 

`java -jar json-data-generator-1.0.0.jar eventsConfig.json`


#### Ejecución y configuración de Presto

**FIX:** Cambiar el /etc/hosts para que se pueda comunicar presto con el composedocker, comprobar que las direcciones corresponden 
```
172.18.0.2	namenode
172.18.0.4	hive-metastore
172.18.0.5	datanode
172.18.0.6	hive-server
```
1. Copiamos el directorio etc en presto y ejecutamos presto
 
`cp -rf etc presto; cd presto/bin`

`./launcher run`

2. Ejecutamos el cliente presto (presto-cli) usando la source y el esquema que queremos
 
`./presto --server localhost:8080 --catalog kafka --schema demo --debug`

`./presto --server localhost:8080 --catalog hive --schema default --debug`

`./presto --server localhost:8080 --catalog cassandra --schema apps --debug`

