#!/bin/bash

# add hostname
echo "127.0.0.1 odb.oddgen.org odb" >> /etc/hosts

# cleanup
rm -r -f /tmp/* 
rm -r -f /var/tmp/* \
