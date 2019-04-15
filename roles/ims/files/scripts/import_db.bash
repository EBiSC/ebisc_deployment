#!/bin/bash

docker run --rm \
  -e PGPASSWORD=${PGPASSWORD} \
  -e PGHOST=ims-postgres \
  -e PGUSER=${PGUSER} \
  -e PGDATABASE=${PGDATABASE} \
  --cap-drop=all \
  --net=ebisc \
  -v /tmp/db_dump/ebisc.sql.gz:/tmp/db_dump/ebisc.sql.gz:Z \
  ebisc/postgres:latest \
  sh -c "gunzip -c /tmp/db_dump/ebisc.sql.gz | psql -f -"
