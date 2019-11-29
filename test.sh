#!/bin/bash
  
clear
echo
curl -H"Content-Type: application/json" http://ec2-35-175-150-122.compute-1.amazonaws.com/api/ -d '{"action":"query","mysqlEndpoint":"edqmsmd189pvko.ctgh3xcsicot.us-east-1.rds.amazonaws.com","mysqlPort":"3306","mysqlUsername":"demodb","mysqlPassword":"password","mysqlDatabase":"demodb","query":"SELECT * FROM crimes"}'
echo