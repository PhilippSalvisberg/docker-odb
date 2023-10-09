FROM oraclelinux:8.8

LABEL maintainer="philipp.salvisberg@gmail.com"
LABEL description="Oracle Database Enterprise Edition 19c (ARM) software only"
LABEL build.command="docker build . --platform linux/arm64 --no-cache --progress plain --tag phsalvisberg/odb:19.0sw-arm"

# copy all scripts
ADD assets /assets/

# image setup via shell script to reduce layers and optimize final disk usage
RUN /assets/db_setup.sh
