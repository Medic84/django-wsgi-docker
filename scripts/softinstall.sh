#!/bin/bash

echo "Soft Installing"
apt-get -y update > /dev/null
apt-get -y install openssl git vim unzip nginx apache2 libapache2-mod-wsgi-py3 openssh-server > /dev/null