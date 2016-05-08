# oddgen Demo Using An Oracle Database 12.1.0.2 Standard Edition

[![](https://badge.imagelayers.io/phsalvisberg/oddgendemo:latest.svg)](https://imagelayers.io/?images=phsalvisberg/oddgendemo:latest 'Get your own badge on imagelayers.io')

## Content

This Dockerfile is based on Maksym Bilenko's work for [sath89/oracle-12c](https://hub.docker.com/r/sath89/oracle-12c/). The resulting image contains the following:

* Ubuntu 14.04.3 LTS
* Oracle Database 12.1.0.2 Standard Edition 
	* Sample schemas SCOTT, HR, OE, PM, IX, SH (without partitioned table sales, costs), BI
	* APEX 5.0.3
	* FTLDB 1.5.0RC
	* tePLSQL 2016-05-02
	* oddgen example/tutorial schemas ODDGEN, OGDEMO
	
Pull the latest trusted build from [here](https://hub.docker.com/r/phsalvisberg/oddgendemo/).


## Installation

### Using Default Settings (recommended)

1. ```docker pull phsalvisberg/oddgendemo```
2. ```docker run -d -p 8082:8082 -p 1521:1521 -h xe --name xe phsalvisberg/oddgendemo```
3. wait around **30 minutes** until the Oracle Database is created and APEX is patched to the latest version. Check logs with ```docker logs xe```. The container is ready to use when the last line in the log is ```Database ready to use. Enjoy! ;)```. The container stops if an error occurs. Check the logs to determine how to proceed.

Feel free to stop using the docker container ```docker stop xe```. The container should shutdown the database gracefully and persist the data. Next time you start the container using ```docker start xe``` the database will be just started and not re-created.


### Options

#### Environment Variables

You may set the environment variables in the docker run statement to configure the container setup process. The following table lists all environment variables with its default values:

Environment variable | Default value | Comments
-------------------- | ------------- | --------
WEB_CONSOLE | ```true``` | Set to ```false``` If you do not need APEX and the Enterprise Manger console
DBCA_TOTAL_MEMORY | ```2048```| Keep in mind that DBCA fails if you set this value too low
APEX_PASS | ```Oracle12c!```| Set a different initial APEX ADMIN password (the one which must be changed on first login)
PASS | ```oracle```| Password for SYS and SYSTEM
PORT | ```1521```| 
HTTP_PORT | ```8082```|

Here's an example run call amending the SYS/SYSTEM password and DBCA memory settings:

```
docker run -e PASS=manager -e DBCA_TOTAL_MEMORY=1536 -d -p 8082:8082 -p 1521:1521 -h xe --name xe phsalvisberg/oddgendemo
```

#### Volumes

The image defines a volume for ```/u01/app/oracle```. You may map this volume to a storage solution of your choice. Here's an example using Flocker:

```
docker run --volume-driver=flocker -v my-volume:/u01/app/oracle -d -p 8082:8082 -p 1521:1521 -h xe --name xe phsalvisberg/oddgendemo
```

It's important to note, that Docker's default volume driver to map host directories might not be suited for this image, at least not with the Docker for Mac Version 1.11.1-beta10 (build: 6662).

The volume driver must provide proper size information, otherwise the Oracle installation will fail with a message as follows:

```
/u01/app/oracle/ does not have enough space. Required space is 1580 MB , available space is 861 MB.
```

The reported available space may vary (zero is not unusual). But it is most probably different to the real available space.


## Access To Database Services

### Enterprise Manager Database Express 12c

[http://localhost:8082/em/](http://localhost:8082/em/)

User | Password 
-------- | -----
system | oracle
sys | oracle


### APEX

[http://localhost:8082/apex/](http://localhost:8082/apex/)

Property | Value 
-------- | -----
Workspace | INTERNAL
User | ADMIN
Password | Oracle12c!

### Database Connections

To access the database e.g. from SQL Developer you configure the following properties:

Property | Value 
-------- | -----
Hostname | localhost
Port | 1521
SID | xe
Service | xe.oracle.docker

The configured user with their credentials are:

User | Password 
-------- | -----
system | oracle
sys | oracle
scott | tiger
hr | hr
oe | oe
pm | pm
ix | ix
sh | sh
bi | bi
ftldb | ftldb
teplsql | teplsql
oddgen | oddgen
ogdemo | ogdemo

Use the following connect string to connect as scott via SQL*Plus or SQLcl: ```scott/tiger@localhost/xe.oracle.docker```

You may configure also TNS entry, e.g. use the XE entry in this [tnsnames.ora](https://github.com/PhilippSalvisberg/docker-oddgendemo/blob/master/tnsnames.ora).  

## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/). 

* [Existing issues](https://github.com/PhilippSalvisberg/docker-oddgendemo/issues)
* [submit new issue](https://github.com/PhilippSalvisberg/docker-oddgendemo/issues/new).

## License

docker-oddgendemo is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>. 
