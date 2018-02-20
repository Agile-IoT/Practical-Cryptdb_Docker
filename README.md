##### This project is about investigating the encrypted database [CryptDB](https://css.csail.mit.edu/cryptdb/) developed at MIT in 2011.
* Currently, the most actively maintained cryptDB repository is located at [yiwenshao/Practical-Cryptdb](https://github.com/yiwenshao/Practical-Cryptdb).
* This Dockerfile deploys the project into a runnable docker container base on Ubuntu 16.04.

## How to setup:

##### 1. Make sure to have Docker installed

http://docs.docker.com/v1.8/installation/

###### This setup is for Linux. For OS X and Windows, install Docker Toolbox and skip the sudo part of the commands.

##### 2. Create a folder, clone project and navigate to folder containing the Dockerfile

    git clone https://github.com/agile-iot/Practical-Cryptdb_Docker.git

##### 3. Build docker image

    sudo docker build -t **name-of-image**:**version** **.**

    #Example:
    sudo docker build -t cryptdb:v1 .
    
    #To build without caching use:
    sudo docker build --no-cache=true -t cryptdb:v1 .

(Open the Docker Quickstart Terminal if OS X or Windows)

##### 4. Run docker container based built image

    sudo docker run -d --name **name-of-container** -p **port-in**:3399 **name-of-image**:**version**

    #Example:
    sudo docker run -d --name cryptdb_v1 -p 3399:3399 cryptdb:v1

Cryptdb server will start automatically and is accessible through the spcified **port-in**
