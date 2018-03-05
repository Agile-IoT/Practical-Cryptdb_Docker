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
    sudo docker build -t cryptdb:v1 .
    
    #To build without caching use:
    sudo docker build --no-cache=true -t cryptdb:v1 .

(Open the Docker Quickstart Terminal if OS X or Windows)

##### 5. Run docker container based built image

    sudo docker run -d --name **name-of-container** -p **port-in**:3399 **name-of-image**:**version**

    #Example:
    sudo docker run -d --name cryptdb_v1 -p 3399:3399 cryptdb:v1

Cryptdb server will start automatically and is accessible through the specified **port-in**

### To use CryptDB in a stack, add the following to docker-compose.yml

    agile-cryptdb:
      container_name: agile-cryptdb
      hostname: agile-cryptdb
      image: agileiot/Practical-Cryptdb_Docker
      restart: always
      depends_on:
        - agile-cryptdb-backend
      ports:
        - 3399:3399/tcp

    agile-cryptdb-backend:
      container_name: agile-cryptdb-backend
      hostname: agile-cryptdb-backend
      image: agileiot/agile-cryptdb-backend
      restart: always
      ports:
        - 3306:3306/tcp
      environment:
        MYSQL_ROOT_PASSWORD: root
      volumes:
        - $DATA/agile-cryptdb-backend:/var/lib/mysql

This will start both, the MySQL backend with the CryptDB libraries and the CryptDB proxy. It is possible to run the two components on different devices. 