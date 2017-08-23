FROM python:3.4
MAINTAINER sysanotes.blogspot.com

ENV PIP_REQUIRE_VIRTUALENV false

ADD scripts/softinstall.sh /root/softinstall.sh
RUN /bin/bash /root/softinstall.sh
RUN rm /root/softinstall.sh

RUN pip install django mysqlclient

ADD config/apache/django.conf /etc/apache2/sites-enabled/django.conf
ADD config/nginx/django.conf /etc/nginx/sites-enabled/django
RUN rm /etc/nginx/sites-enabled/default
RUN sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
RUN a2dissite 000-default.conf

WORKDIR /var/www

RUN django-admin startproject djanapp
RUN mkdir djanapp/static && mkdir djanapp/media

ADD scripts/mysqlinstall.sh /root/mysqlinstall.sh
RUN /bin/bash /root/mysqlinstall.sh
RUN rm /root/mysqlinstall.sh

ADD requirements.txt djanapp/requirements.txt
RUN pip install -r djanapp/requirements.txt

RUN service mysql start && python djanapp/manage.py migrate

EXPOSE 22 80 8080 443

ENTRYPOINT service ssh restart && service nginx restart && service apache2 restart && service mysql restart && bash