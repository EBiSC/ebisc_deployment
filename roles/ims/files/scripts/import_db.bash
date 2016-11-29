#!/bin/bash

docker run --rm \
  -e PG_PASSWORD=${PG_ADMIN_PASSWORD} \
  -e PG_HOST=ims-postgres \
  -e PG_USER=postgres \
  --cap-drop=all \
  --net=ebisc \
  -v /tmp/:/tmp/ \
  ebisc/postgres:latest \
  sh -c "dropdb ${PG_DATABASE}; createdb ${PG_DATABASE} && gunzip -c /tmp/db.gz | psql -d ${PG_DATABASE} -f -"
