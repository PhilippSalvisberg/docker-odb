FROM oraclelinux:7.9

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 21c software only"
LABEL build.command="docker build . --no-cache --progress plain --tag phsalvisberg/odb:21.0sw"

# copy all scripts
ADD assets /assets/

# image setup via shell script to reduce layers and optimize final disk usage
RUN /assets/db_setup.sh
