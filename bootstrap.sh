#!/bin/sh
#
# bootstrap.sh - Script to setup an Amazon ElastiCache environment for PHP
# Copyright 2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed 
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
# express or implied. See the License for the specific language governing 
# permissions and limitations under the License.
#

if [ "$#" -lt 5 ]; then
        echo "Usage: $0 <elasticache_endpoint> <elasticache_port> <mysql_endpoint> <mysql_username> <mysql_database>"
        exit 1
fi

elasticache_endpoint="$1"
elasticache_port="$2"
mysql_endpoint="$3"
mysql_username="$4"
mysql_database="$5"
elasticache_token="$6"


# setup instance
sleep 5
yum -y install httpd mod_wsgi unzip python-pip
amazon-linux-extras install -y php7.2 lamp-mariadb10.2-php7.2
pip install flask redis

# prepare php application
git clone https://github.com/awslabs/elasticache-hybrid-architecture-demo
cd elasticache-hybrid-architecture-demo
sed -e "s/{ELASTICACHE_ENDPOINT}/${elasticache_endpoint}/g" \
    -e "s/{ELASTICACHE_PORT}/${elasticache_port}/g" \
        -e "s/{ELASTICACHE_TOKEN}/${elasticache_token}/g" \
        -e "s/{MYSQL_ENDPOINT}/${mysql_endpoint}/g" \
        -e "s/{MYSQL_USERNAME}/${mysql_username}/g" \
        -e "s/{MYSQL_DATABASE}/${mysql_database}/g" \
        config_template.php > config.php

sed -e "s/{ELASTICACHE_ENDPOINT}/${elasticache_endpoint}/g" \
    -e "s/{ELASTICACHE_PORT}/${elasticache_port}/g" \
        -e "s/{ELASTICACHE_TOKEN}/${elasticache_token}/g" \
        -e "s/{MYSQL_ENDPOINT}/${mysql_endpoint}/g" \
        -e "s/{MYSQL_USERNAME}/${mysql_username}/g" \
        -e "s/{MYSQL_DATABASE}/${mysql_database}/g" \
        config_template.yaml > api/config.yaml

# prepare sample data
unzip sample-dataset-crimes-2012-2015.csv.zip
mv sample-dataset-crimes-2012-2015.csv crimes-2012-2015.csv

# download predis client
git clone git://github.com/nrk/predis.git

# move to document root
mv server.conf /etc/httpd/conf.d/
mv * /var/www/html/
chown -R apache /var/www/html/
chmod 0644 /var/www/html/demo.php
chmod 0700 /var/www/html/api/rest.wsgi

# enable http service
systemctl enable httpd.service
systemctl start httpd.service