#!/bin/bash

docker run --rm \
  -e PG_PASSWORD=${PG_PASSWORD} \
  --cap-drop=all \
  --net=ebisc \
  -v /tmp/:/tmp/ \
  ebisc/postgres:latest \
  sh -c "pg_dump -h ims-postgres -U ${POSTGRESQL_USER} -d ${POSTGRESQL_DATABASE} | gzip -c > /tmp/db.backup.gz"
