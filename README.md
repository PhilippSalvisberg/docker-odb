# Docker Base Image for Oracle Database 12.2.0.1 Enterprise Edition

## Content

This image contains the following:

* Oracle Linux 7.3
* Oracle Database 12.2.0.1 Enterprise Edition software installation
* Sample schemas HR, OE, PM, IX, SH, BI (master branch as of build time)
* APEX 5.1.1
* Oracle SQLcl: Release 4.2.0.16.355.0402
	
Pull the latest build from [Docker Hub](https://hub.docker.com/r/phsalvisberg/oracle12ee/).

The purpose of this image is provide all software components to create Oracle database instances including sample schemas and APEX. The intended use is for other images such as

   * [PhilippSalvisberg/docker-oddgendemo](https://github.com/PhilippSalvisberg/docker-oddgendemo)
   * [PhilippSalvisberg/docker-oddgendemo-cdb](https://github.com/PhilippSalvisberg/docker-oddgendemo-cdb)
    
## Environment Variable

The following environement variable have been used for the installation:

Environment variable | Value
-------------------- | -------------
ORACLE_BASE | ```/u01/app/oracle```
ORACLE_HOME | ```/u01/app/oracle/product/12.2.0.1/dbhome```

## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/): 

* [Existing issues](https://github.com/PhilippSalvisberg/docker-oracle12ee/issues)
* [submit new issue](https://github.com/PhilippSalvisberg/docker-oracle12ee/issues/new)

## License

docker-oddgendemo is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>. 

See [Oracle Database Licensing Information User Manual](http://docs.oracle.com/database/121/DBLIC/editions.htm#DBLIC109) regarding Oracle Database licenses.
