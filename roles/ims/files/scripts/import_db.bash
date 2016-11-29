#!/bin/bash

docker run --rm \
  -e PGPASSWORD=${PGPASSWORD} \
  -e PGHOST=ims-postgres \
  -e PGUSER=${PGUSER} \
  -e PGDATABASE=${PGDATABASE} \
  --cap-drop=all \
  --net=ebisc \
  -v /tmp/:/tmp/ \
  ebisc/postgres:latest \
  sh -c "gunzip -c /tmp/ebisc.sql.gz | psql -f -"
