#!/bin/bash

nginx_port=80
apache_port=8080
ssh_port=222

if [ "$EUID" -ne 0 ]
  then echo "This script needs root privileges"
  exit
fi

echo "Installing django-wsgi-docker"
docker build . --rm --tag="medic84/django-wsgi-docker" --no-cache

echo "Running docker container"
docker run -itd --restart=always -p ${nginx_port}:80 -p ${apache_port}:8080 -p ${ssh_port}:22 medic84/django-wsgi-docker