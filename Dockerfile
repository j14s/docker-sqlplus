FROM ubuntu as base
MAINTAINER johnthughes

RUN apt-get -y update && \
    apt-get -y install libaio1 unzip rlwrap && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/*

#Throw away layer for unziping
FROM base AS unzipper

WORKDIR /instantclient_19_6    

ADD instantclient-basic-linux.x64-19.6.0.0.0dbru.zip /instantclient_19_6
ADD instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip /instantclient_19_6
ADD instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip /instantclient_19_6
ADD instantclient-jdbc-linux.x64-19.6.0.0.0dbru.zip /instantclient_19_6
RUN unzip instantclient-basic-linux.x64-19.6.0.0.0dbru.zip
RUN unzip instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip
RUN unzip instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip
RUN unzip instantclient-jdbc-linux.x64-19.6.0.0.0dbru.zip

RUN rm -rf *.zip

#Final layer with just the goods
FROM base

COPY --from=1 /instantclient_19_6 .
ENV LD_LIBRARY_PATH /instantclient_19_6

# CMD instantclient_19_6/sqlplus <user>/<password>@//xxx.yyy.eu-west-1.rds.amazonaws.com:1521/ORCL
CMD sleep 1; rlwrap /instantclient_19_6/sqlplus $URL

