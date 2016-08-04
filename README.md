# oddgen Demo using an Oracle Database 12.1.0.2 Enterprise Edition with non-CDB Architecture

## Content

This image contains the following:

* Oracle Linux 7.2
* Oracle Database 12.1.0.2 Enterprise Edition with non-CDB architecture
	* Sample schemas SCOTT, HR, OE, PM, IX, SH, BI (master branch as of build time)
	* APEX 5.0.4
	* FTLDB 1.5.0-RC
	* tePLSQL (master branch as of build time)
	* oddgen example/tutorial schemas ODDGEN, OGDEMO (master branch as of build time)
* OpenJDK Runtime Environment (build 1.8.0_91-b14)
* Oracle SQLcl: Release 4.2.0.16.175.1027 RC 
	
Pull the latest build from [Docker Hub](https://hub.docker.com/r/phsalvisberg/oddgendemo/).

Please note that the non-CDB architecture is deprecated with Oracle 12.1.0.2. See [Oracle Database Upgrade Guide](https://docs.oracle.com/database/121/UPGRD/deprecated.htm#BABDBCJI) and [Readme Information for Oracle Database 12c Release 1 (12.1.0.2)](https://docs.oracle.com/database/121/READM/chapter12102.htm#READM120) for more information.

See [docker-oddgendemo-cdb](https://github.com/PhilippSalvisberg/docker-oddgendemo-cdb) if you are interested in a CDB variant of this image.

## Installation

### Using Default Settings (recommended)

Complete the following steps to create a new container:

1. Pull the image (optional)

		docker pull phsalvisberg/oddgendemo

2. Create the container

		docker run -d -p 8082:8082 -p 1521:1521 -h odb --name odb phsalvisberg/oddgendemo
		
3. wait around **30 minutes** until the Oracle database instance is created and APEX is patched to the latest version. Check logs with ```docker logs odb```. The container is ready to use when the last line in the log is ```Database ready to use. Enjoy! ;-)```. The container stops if an error occurs. Check the logs to determine how to proceed.

Feel free to stop the docker container after a successful installation with ```docker stop odb```. The container should shutdown the database gracefully and persist the data fully (ready for backup). Next time you start the container using ```docker start odb``` the database will start up.


### Options

#### Environment Variables

You may set the environment variables in the docker run statement to configure the container setup process. The following table lists all environment variables with its default values:

Environment variable | Default value | Comments
-------------------- | ------------- | --------
WEB_CONSOLE | ```true``` | Set to ```false``` If you do not need APEX and Enterprise Manger Database Express 12c
DBCA_TOTAL_MEMORY | ```2048```| Keep in mind that DBCA fails if you set this value too low
ORACLE_SID | ```odb```| The Oracle SID
SERVICE_NAME | ```odb.docker``` | The Oracle Service Name
APEX_PASS | ```Oracle12c!```| Initial APEX ADMIN password
PASS | ```oracle```| Password for SYS and SYSTEM

Here's an example run call amending the SYS/SYSTEM password and DBCA memory settings:

```
docker run -e PASS=manager -e DBCA_TOTAL_MEMORY=1536 -d -p 8082:8082 -p 1521:1521 -h odb --name odb phsalvisberg/oddgendemo
```

#### Volumes

The image defines a volume for ```/u01/app/oracle```. You may map this volume to a storage solution of your choice. Here's an example using a named volume ```odb```:

```
docker run -v odb:/u01/app/oracle -d -p 8082:8082 -p 1521:1521 -h odb --name odb phsalvisberg/oddgendemo
```

Here's an example mapping the local directory ```$HOME/docker/odb/u01/app/oracle``` to ```/u01/app/oracle```. 

```
docker run -v $HOME/docker/odb/u01/app/oracle:/u01/app/oracle -d -p 8082:8082 -p 1521:1521 -h odb --name odb phsalvisberg/oddgendemo
```

**Please note**: Volumes mapped to local directories are not stable, at least not in Docker for Mac 1.12.0. E.g. creating a database may never finish. So I recommend not to use local mapped directories for the time being. Alternatively you may use a volume plugin. A comprehensive list of volume plugins is listed [here](https://docs.docker.com/engine/extend/plugins/#volume-plugins).

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
SID | odb
Service | odb.docker

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

Use the following connect string to connect as scott via SQL*Plus or SQLcl: ```scott/tiger@localhost/odb.docker```

## Backup

Complete the following steps to backup the data volume:

1. Stop the container with 

		docker stop odb
		
2. Backup the data volume to a compressed file ```odb.tar.gz``` in the current directory with a little help from the ubuntu image

		docker run --rm --volumes-from odb -v $(pwd):/backup ubuntu tar czvf /backup/odb.tar.gz /u01/app/oracle
		
3. Restart the container

		docker start odb

## Restore

Complete the following steps to restore an image from scratch. There are other ways, but this procedure is also applicable to restore a database on another machine:

1. Stop the container with 

		docker stop odb

2. Remove the container with its associated volume 

		docker rm -v odb
		
3. Remove unreferenced volumes, e.g. explicitly created volumes by previous restores

		docker volume ls -qf dangling=true | xargs docker volume rm
	
4. Create an empty data volume named ```odb```

		docker volume create --name odb

5. Populate data volume ```odb``` with backup from file ```odb.tar.gz``` with a little help from the ubuntu image

		docker run --rm -v odb:/u01/app/oracle -v $(pwd):/backup ubuntu tar xvpfz /backup/odb.tar.gz -C /			

6. Create the container using the ```odb```volume

		docker run -v odb:/u01/app/oracle -d -p 8082:8082 -p 1521:1521 -h odb --name odb phsalvisberg/oddgendemo
		
7. Check log of ```odb``` container

		docker logs odb
	
	The end of the log should look as follows:
	
		Reuse existing database.

		(...)

		Database ready to use. Enjoy! ;-)

## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/): 

* [Existing issues](https://github.com/PhilippSalvisberg/docker-oddgendemo/issues)
* [submit new issue](https://github.com/PhilippSalvisberg/docker-oddgendemo/issues/new)

## Credits
This Dockerfile is based on the following work:

- Maksym Bilenko's GitHub project [sath89/docker-oracle-12c](https://github.com/MaksymBilenko/docker-oracle-12c)
- Frits Hoogland's blog post [Installing the Oracle database in docker](https://fritshoogland.wordpress.com/2015/08/11/installing-the-oracle-database-in-docker/)

## License

docker-oddgendemo is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>. 

See [Oracle Database Licensing Information User Manual](http://docs.oracle.com/database/121/DBLIC/editions.htm#DBLIC109) regarding Oracle Database licenses.
