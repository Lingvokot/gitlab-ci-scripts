#!/bin/bash

apt-get install nginx nginx-extra

mkdir -m 0755 /opt/gitlab-ci-builds/
mkdir -m 0755 /opt/gitlab-ci-builds/builds/
chown -R gitlab-runner:gitlab-runner /opt/gitlab-ci-builds/

# copy build-export to /opt/gitlab-ci-builds/build-export.sh and then...
# chmod +x /opt/gitlab-ci-builds/build-export.sh

# copy config and then..
# unlink /etc/nginx/sites-enabled/default
# ln -s /etc/nginx/sites-available/nginx-config /etc/nginx/sites-enabled/default

# copy nginx-passwords to /etc/nginx/nginx-passwords and then ...

# then...
# service nginx configtest
# service nginx reload

# install php for simple badge logic
apt-get install php5-common php5-cgi php5-fpm

# replace php.ini in /etc/php5/fpm/php.ini

# then... 
# service php5-fpm restart
