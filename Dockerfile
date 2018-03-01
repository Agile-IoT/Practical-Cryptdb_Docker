FROM ubuntu:16.04

MAINTAINER firsti

# make sure the package repository is up to date
RUN apt-get update

# Install stuff
RUN apt-get install -y ca-certificates sudo ruby git less net-tools

ENV CRYPTDB_PASS=root
ENV CRYPTDB_USER=root
ENV BACKEND_ADDRESS=agile-cryptdb-backend
ENV BACKEND_PORT=3306

RUN echo 'root:root' |chpasswd

# Default root password will be $CRYPTDB_PASS
RUN echo "mysql-server mysql-server/root_password password $CRYPTDB_PASS" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password $CRYPTDB_PASS" | debconf-set-selections

# Clone project repository
RUN git clone https://github.com/yiwenshao/Practical-Cryptdb.git /opt/cryptdb
WORKDIR /opt/cryptdb

# Adding debian compatibility to apt syntax
RUN sed -i 's/apt /apt-get /g' INSTALL.sh

# Setup
RUN ./INSTALL.sh

# Change variables such that cryptdb starts automatically, it is accessible from outside and according to environment variables
RUN sed -i -e"s/^proxy-address\s*=\s*127.0.0.1:3399/proxy-address = 0.0.0.0:3399/" mysql-proxy.cnf
RUN sed -i -e"s/^proxy-backen-addresses\s*=\s*127.0.0.1:3306/proxy-backend-addresses = $BACKEND_ADDRESS:$BACKEND_PORT/" mysql-proxy.cnf
RUN sed -i -e"s#mysql-proxy #mysql-src/mysql-proxy-0.8.5/bin/mysql-proxy #g" cdbserver.sh
CMD ["/bin/bash", "-c", "/opt/cryptdb/cdbserver.sh"]

# Expose cryptdb port
EXPOSE 3399
