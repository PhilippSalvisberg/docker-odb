# oddgen Demo Using An Oracle Database 12c Standard Edition 2

[![](https://badge.imagelayers.io/phsalvisberg/oddgendemo:latest.svg)](https://imagelayers.io/?images=phsalvisberg/oddgendemo:latest 'Get your own badge on imagelayers.io')

## Content

This Dockerfile is based on Maksym Bilenko's work for [sath89/oracle-12c](https://hub.docker.com/r/sath89/oracle-12c/). The resulting image contains the following:

* Ubuntu 14.04.3 LTS
* Oracle Database 12.1.0.2 Standard Edition 2
	* Sample schemas SCOTT, HR, OE, PM, IX, SH (without partitioned table sales, costs), BI
	* APEX 5.0.3
	* FTLDB 1.5.0
	* tePLSQL (master branch as of build time)
	* oddgen example/tutorial schemas ODDGEN, OGDEMO (master branch as of build time)
	
Pull the latest trusted build from [here](https://hub.docker.com/r/phsalvisberg/oddgendemo/).


## Installation

### Using Default Settings (recommended)

Complete the following steps to create a new container:

1. Pull the image

		docker pull phsalvisberg/oddgendemo

2. Create the container

		docker run -d -p 8082:8082 -p 1521:1521 -h xe --name xe phsalvisberg/oddgendemo
		
3. wait around **30 minutes** until the Oracle Database is created and APEX is patched to the latest version. Check logs with ```docker logs xe```. The container is ready to use when the last line in the log is ```Database ready to use. Enjoy! ;)```. The container stops if an error occurs. Check the logs to determine how to proceed.

Feel free to stop the docker container after a successful installation with ```docker stop xe```. The container should shutdown the database gracefully and persist the data fully (ready for backup). Next time you start the container using ```docker start xe``` the database will start up.


### Options

#### Environment Variables

You may set the environment variables in the docker run statement to configure the container setup process. The following table lists all environment variables with its default values:

Environment variable | Default value | Comments
-------------------- | ------------- | --------
WEB_CONSOLE | ```true``` | Set to ```false``` If you do not need APEX and the Enterprise Manger console
DBCA_TOTAL_MEMORY | ```2048```| Keep in mind that DBCA fails if you set this value too low
APEX_PASS | ```Oracle12c!```| Set a different initial APEX ADMIN password (the one which must be changed on first login)
PASS | ```oracle```| Password for SYS and SYSTEM
PORT | ```1521```| The database port number used in the container. Since you have to define the ```-p``` parameter anyway when creating a containerto, it is easier to change the port mapping there. E.g. to use port 1522 on the host use ```-p 1522:1521```
HTTP_PORT | ```8082```| The http port number used in the container for EM and APEX. Since you have to define the ```-p``` parameter anyway when creating a containerto, it is easier to change the port mapping there. E.g. to use port 8080 on the host use ```-p 8080:8082```

Here's an example run call amending the SYS/SYSTEM password and DBCA memory settings:

```
docker run -e PASS=manager -e DBCA_TOTAL_MEMORY=1536 -d -p 8082:8082 -p 1521:1521 -h xe --name xe phsalvisberg/oddgendemo
```

#### Volumes

The image defines a volume for ```/u01/app/oracle```. You may map this volume to a storage solution of your choice. Here's an example using a named volume ```xe```:

```
docker run -v xe:/u01/app/oracle -d -p 8082:8082 -p 1521:1521 -h xe --name xe phsalvisberg/oddgendemo
```

It's important to note, that mapping a host directory might not work with this image, at least not with the Docker for Mac Version 1.11.1-beta10 (build: 6662). The volume driver must provide proper size information, otherwise the Oracle installation will fail with a message as follows:

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

## Backup

Complete the following steps to backup the data volume:

1. Stop the container with 

		docker stop xe
		
2. Backup the data volume to a compressed file ```xe.tar.gz``` in the current directory with a little help from the ubuntu image

		docker run --rm --volumes-from xe -v $(pwd):/backup ubuntu tar czvf /backup/xe.tar.gz /u01/app/oracle
		
3. Restart the container

		docker start xe

## Restore

Complete the following steps to restore an image from scratch. There are other ways, but this procedure is also applicable to restore a database on another machine:

1. Stop the container with 

		docker stop xe

2. Remove the container with its associated volume 

		docker rm -v xe
		
3. Remove unreferenced volumes, e.g. explicitly created volumes by previous restores

		docker volume ls -qf dangling=true | xargs docker volume rm
	
4. Create an empty data volume named ```xe```

		docker volume create --name xe 

5. Populate data volume ```xe``` with backup from file ```xe.tar.gz``` with a little help from the ubuntu image

		docker run --rm -v xe:/u01/app/oracle -v $(pwd):/backup ubuntu tar xvpfz /backup/xe.tar.gz -C /			

6. Create the container using the ```xe```volume

		docker run -v xe:/u01/app/oracle -d -p 8082:8082 -p 1521:1521 -h xe --name xe phsalvisberg/oddgendemo
		
7. Check log of ```xe``` container

		docker logs xe
	
	The log schould look as follows:
	
		found files in /u01/app/oracle/oradata Using them instead of initial database
		ORACLE instance started.
		
		Total System Global Area 1207959552 bytes
		Fixed Size		    2923776 bytes
		Variable Size		  436208384 bytes
		Database Buffers	  754974720 bytes
		Redo Buffers		   13852672 bytes
		Database mounted.
		Database opened.
		Starting web management console
		
		PL/SQL procedure successfully completed.

		Web management console initialized. Please visit 
		   - http://localhost:8082/em 
		   - http://localhost:8082/apex
		   
		Database ready to use. Enjoy! ;)

## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/). 

* [Existing issues](https://github.com/PhilippSalvisberg/docker-oddgendemo/issues)
* [submit new issue](https://github.com/PhilippSalvisberg/docker-oddgendemo/issues/new).

## License

docker-oddgendemo is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>. 

See [Oracle Database Licensing Information User Manual](http://docs.oracle.com/database/121/DBLIC/editions.htm#DBLIC109) and [Oracle Database 12c Standard Edition 2](https://www.oracle.com/database/standard-edition-two/index.html) for further information.
