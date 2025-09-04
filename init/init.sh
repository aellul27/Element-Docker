#!/bin/bash

set -e
#set -x

if [[ ! -s /secrets/postgres/postgres_password ]]
then
	mkdir -p /secrets/postgres
	head -c16 /dev/urandom | base64 | tr -d '=' > /secrets/postgres/postgres_password
fi