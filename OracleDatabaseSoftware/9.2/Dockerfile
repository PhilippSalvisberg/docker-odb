FROM pivotaldata/centos:5

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 9.2 software only"
LABEL build.command="docker build . --tag phsalvisberg/odb:9.2sw"

# copy all scripts
ADD assets /assets/

# image setup via shell script to reduce layers and optimize final disk usage
RUN /assets/db_setup.sh
