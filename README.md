##### This project is about investigating the encrypted database [CryptDB](https://css.csail.mit.edu/cryptdb/) developed at MIT in 2011.
* This repository uses [agile-cryptdb-backend](https://github.com/Agile-IoT/agile-cryptdb-backend) as the backend MySQL server.
* CryptDB libraries are required on both the backend and this CryptDB proxy. Therefore, a MySQL server without these libraries as the database will not work.
* CryptDB currently does not compile on ARM devices.
* This Dockerfile deploys the project into a runnable docker container base on Ubuntu 16.04.

## How to setup:

##### 1. Make sure to have Docker installed

http://docs.docker.com/v1.8/installation/

###### This setup is for Linux. For OS X and Windows, install Docker Toolbox and skip the sudo part of the commands.

##### 2. Create a folder, clone project and navigate to folder containing the Dockerfile

    git clone https://github.com/agile-iot/Practical-Cryptdb_Docker.git

##### 3. Make changes to the environment variables, such that the username and password for cryptdb is set and the location of the backend database is specified

    ENV CRYPTDB_PASS=**PASSWORD**
    ENV CRYPTDB_USER=**USERNAME**
    ENV BACKEND_ADDRESS=**IP**
    ENV BACKEND_PORT=**PORT**

    #Example
    ENV CRYPTDB_PASS=root
    ENV CRYPTDB_USER=root
    ENV BACKEND_ADDRESS=agile-cryptdb-backend
    ENV BACKEND_PORT=3306

##### 4. Build docker image

    sudo docker build -t **name-of-image**:**version** **.**

    #Example:
    sudo docker build -t agile-cryptdb .
    
    #To build without caching use:
    sudo docker build --no-cache=true -t agile-cryptdb .

(Open the Docker Quickstart Terminal if OS X or Windows)

##### 5. Run docker container based built image

    sudo docker run -d --name **name-of-container** -p **port-in**:3399 **name-of-image**:**version**

    #Example:
    sudo docker run -d --name agile-cryptdb -p 3399:3399 agile-cryptdb

Cryptdb server will start automatically and is accessible through the specified **port-in**

### To use CryptDB in a stack, add the following to docker-compose.yml

    agile-cryptdb:
      container_name: agile-cryptdb
      hostname: agile-cryptdb
      image: agile-cryptdb
      restart: always
      depends_on:
        - agile-cryptdb-backend
      ports:
        - 3399:3399/tcp

    agile-cryptdb-backend:
      container_name: agile-cryptdb-backend
      hostname: agile-cryptdb-backend
      image: agile-cryptdb-backend
      restart: always
      ports:
        - 3306:3306/tcp
      environment:
        MYSQL_ROOT_PASSWORD: root
      volumes:
        - $DATA/agile-cryptdb-backend:/var/lib/mysql

This will start both, the MySQL backend with the CryptDB libraries and the CryptDB proxy. It is possible to run the two components on different devices.

**Note:** The instructions to build <code>agile-cryptdb-backend</code> can be found [here](https://github.com/Agile-IoT/agile-cryptdb-backend).
## Troubleshooting
### 1. Error when trying the use an existing database or table
    
    MySQL [NULL]> use mysql
    Database changed
    MySQL [mysql]> show tables;
    ERROR 4095 (fail1): (main/dml_handler.cc, 1684)
    failed to find the database 'mysql'
    
This means you are trying to use a database or tables that were not generated through the current CryptDB proxy instance. 

Either the database that you are trying to use was created by a plain MySQL client or another CryptDB proxy instance. This is not possible, since CryptDB uses symmetric encryption and the keys are not known to the current CryptDB instance.
### 2. I am seeing this error in the logs:

    agile-cryptdb | mysql-proxy: main/rewrite_main.cc:163: bool tablesSanityCheck(SchemaInfo&, const std::unique_ptr<Connect>&, const std::unique_ptr<Connect>&): Assertion `meta_tables.size() == anon_name_map.size()' failed.
    agile-cryptdb | /opt/cryptdb/cdbserver.sh: line 2: 10 Aborted mysql-src/mysql-proxy-0.8.5/bin/mysql-proxy --defaults-file=./mysql-proxy.cnf --proxy-lua-script=`pwd`/wrapper.lua

This is a serious error. It means the proxy had a fatal error, e.g. the database was corrupted. We encountered this when trying to create a table that already exists together with <code>IF NOT EXISTS</code> in the query, for example:

    CREATE TABLE IF NOT EXISTS user (ID int AUTO_INCREMENT, User VARCHAR(255), Password VARCHAR(255), PRIMARY KEY(ID));

Omitting <code>IF NOT EXISTS</code> lets the proxy fail securely when trying to add a table that already exists, which can be then handled in the application.
 
To recover from the error above, the database needs to be recreated (<code>DROP/CREATE</code> on the backend database) as well as the CryptDB proxy needs to be removed and started again (<code>docker-compose rm agile-cryptdb && docker-compose up agile-cryptdb</code>).

