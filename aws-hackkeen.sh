#!/bin/bash

bucket=$1
echo "[+] Testing by abhhi" > test.txt

echo "[+] Testing for " $bucket
aws s3api get-bucket-acl --bucket my-bucket --no-sign-request
aws s3 ls s3://$bucket --no-sign-request
aws s3 mv test.txt s3://$bucket --no-sign-request
aws s3 cp test.txt s3://$bucket --no-sign-request
aws s3 rm s3://$bucket --no-sign-request

rm test.txt

echo " "
echo "----------------"
