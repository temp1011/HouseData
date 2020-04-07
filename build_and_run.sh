#!/usr/bin/env bash
set -euo pipefail

# First stop any old running containers
sudo docker stop ptest > /dev/null 2>&1 && echo "Stopped previous running DB"

sudo docker image build -t house_prices_postgres:0.1 .
sudo docker container run -d --rm --name ptest \
	-e POSTGRES_PASSWORD=password \
	-p 5432:5432 \
	house_prices_postgres:0.1

echo "waiting for db to start"

SECONDS=0

until pg_isready -h localhost -d docker -p 5432 -U docker > /dev/null 2>&1 # wait for db to accept connections
do
	sleep 1;
done

echo "DB is ready after $SECONDS seconds"

sudo docker ps
