# docker-odb

## Introduction
docker-odb provides Dockerfiles to build Oracle Database Docker images.

Due to [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) I cannot make the resulting images available on a public Docker registry.

## Components

| Component                     | Version  | Docker Image |
| ----------------------------- | -------- | ------------ |
| [Oracle Database Software](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabaseSoftware)  | [12.1](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabaseSoftware/12.1) | [phsalvisberg/odb:12.1sw](https://hub.docker.com/r/phsalvisberg/odb/tags/) |
| | [12.2](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabaseSoftware/12.2) | [phsalvisberg/odb:12.2sw](https://hub.docker.com/r/phsalvisberg/odb/tags/) |
| | [18.0](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabaseSoftware/18.0) | [phsalvisberg/odb:18.0sw](https://hub.docker.com/r/phsalvisberg/odb/tags/) |
| [Oracle Database](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabase) | [12.1](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabase/12.1) | [phsalvisberg/odb:12.1](https://hub.docker.com/r/phsalvisberg/odb/tags/) |
| | [12.2](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabase/12.2) | [phsalvisberg/odb:12.2](https://hub.docker.com/r/phsalvisberg/odb/tags/) |
| | [18.0](https://github.com/PhilippSalvisberg/docker-odb/blob/master/OracleDatabase/18.0) | [phsalvisberg/odb:18.0](https://hub.docker.com/r/phsalvisberg/odb/tags/) |

## Issues

Please file your bug reports, enhancement requests, questions and other support requests within [Github's issue tracker](https://help.github.com/articles/about-issues/):

* [Existing issues](https://github.com/PhilippSalvisberg/docker-odb/issues)
* [submit new issue](https://github.com/PhilippSalvisberg/docker-odb/issues/new)

## How to Contribute

1. Describe your idea by [submitting an issue](https://github.com/PhilippSalvisberg/docker-odb/issues/new)
2. [Fork the docker-odb respository](https://github.com/PhilippSalvisberg/docker-odb/fork)
3. [Create a branch](https://help.github.com/articles/creating-and-deleting-branches-within-your-repository/), commit and publish your changes and enhancements
4. [Create a pull request](https://help.github.com/articles/creating-a-pull-request/)

## License

docker-odb is licensed under the Apache License, Version 2.0. You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>.

See [OTN Developer License Terms](http://www.oracle.com/technetwork/licenses/standard-license-152015.html) and [Oracle Database Licensing Information User Manual](https://docs.oracle.com/database/122/DBLIC/Licensing-Information.htm#DBLIC-GUID-B6113390-9586-46D7-9008-DCC9EDA45AB4) regarding Oracle Database licenses.