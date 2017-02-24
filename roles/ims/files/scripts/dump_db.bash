#!/bin/bash

docker run --rm \
  -e PGPASSWORD=${PGPASSWORD} \
  -e PGHOST=ims-postgres \
  -e PGUSER=${PGUSER} \
  -e PGDATABASE=${PGDATABASE} \
  --cap-drop=all \
  --net=ebisc \
  -v /tmp/db_dump:/tmp/db_dump:Z \
  ebisc/postgres:latest \
  sh -c "pg_dump | gzip -c > /tmp/db_dump/ebisc.sql.gz"
