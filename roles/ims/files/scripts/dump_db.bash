#!/bin/bash

docker run --rm \
  -e PG_PASSWORD=${PG_PASSWORD} \
  -e PG_HOST=ims-postgres \
  -e PG_USER=${PG_USER} \
  --cap-drop=all \
  --net=ebisc \
  -v /tmp/:/tmp/ \
  ebisc/postgres:latest \
  sh -c "pg_dump -d ${PG_DATABASE} | gzip -c > /tmp/db.backup.gz"
