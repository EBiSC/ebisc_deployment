#!/bin/bash

docker run --rm \
  -e PGPASSWORD=${PG_ADMIN_PASSWORD} \
  -e PGHOST=ims-postgres \
  -e PGUSER=postgres \
  -e PGDATABASE=${PGDATABASE} \
  --cap-drop=all \
  --net=ebisc \
  -v /tmp/:/tmp/ \
  ebisc/postgres:latest \
  sh -c "dropdb -U postgres ${PGDATABASE}; createdb ${PGDATABASE} && gunzip -c /tmp/db.gz | psql -f -"
