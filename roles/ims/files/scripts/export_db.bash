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
  sh -c "psql -d ims -c \"\\copy (select * from $1) to '/tmp/db_dump/$2'\""
