
**Warning** - Read the [ansible.md](ansible.md) documentation before you read this page.  Most of the time, you should configure the VMs using ansible.

VM configuration
===============

All of our VMs use the [coreos](https://coreos.com/) lightweight operating system. Coreos provides only minimal functionality required for deploying applications in docker containers. Apart from docker, almost nothing is installed.

Systemd
-------

Systemd is the coreos init system used for starting and stopping daemons.
Recommended documentation from [freedesktop.org](https://www.freedesktop.org/wiki/Software/systemd/) or [Archlinux](https://wiki.archlinux.org/index.php/Systemd).

We use systemd to start and stop all processes, e.g. postgres, webservers, elasticsearch etc. Generally, this is done with ansible playbooks so you do not need to ssh into the VM.
When you run an ansible playbook, it will copy the systemd unit files onto the remote VM, it will build the docker image, and then enable the unit so it starts on boot.

Our systemd unit files are in this directory:

    /etc/systemd/system/

List running units:

    systemctl list-units

List failed units:

    systemctl --failed

Start a unit immediately:

    sudo systemctl start ims-updates.service 

Journal
-------

Systemd has its own logging system called the journal. You read the journal using [journalctl](https://www.freedesktop.org/software/systemd/man/journalctl.html).

This will show you log from everything:

    journalctl

This will show you logged output from the ims-postgres.service systemd unit:

    journalctl -u ims-postgres.service

Docker
------

You could use the [docker log command](https://docs.docker.com/engine/reference/commandline/logs/) as an alternative way to see logging. For example:

  docker logs ims-postgres

Cron?
----

Cron does not exist.  Instead we use [systemd timers](https://www.freedesktop.org/software/systemd/man/systemd.timer.html) to start up scheduled routine jobs.

A list of systemd units
-----------------------

Look in /etc/systemd/system and you will find these unit files.

###1. IMS

* **ims-nginx.service** - starts the [nginx](https://nginx.org/en/) webserver. This is enabled so it starts up on boot.
* **ims-uwsgi.service** - starts the [uwsgi](https://uwsgi-docs.readthedocs.io/en/latest/) application server to serve the Django app. Enabled so it starts up on boot.
* **ims-postgres.service** - starts the [postgres](https://www.postgresql.org/) database. Enabled so it starts up on boot.
* **ims-elasticsearch.service** - starts [elasticsearch](https://www.elastic.co/). Enabled so it starts up on boot.
* **duplicity.service** - this runs [duplicity](http://duplicity.nongnu.org/duplicity.1.html) to backup our media files to our S3 object store. This is a "oneshot" systemd service, so it is not enabled.
* **duplicity-backups.timer** - this is a timer to run duplicity.service overnight.
* **duplicity-restore.service** - this runs [duplicity](http://duplicity.nongnu.org/duplicity.1.html) to restore the media directory from our S3 object store. It is not enabled. Run it only when you need to.
* **ims-updates.service** - this runs the Django "import all" command. This service must be run nightly, so that it imports from hPSCreg and biosamples and pseudoLIMS.  This is a "oneshot" systemd service, not enabled.
* **ims-updates.timer** - this is a timer to run ims-updates.service overnight.
* **postgres-backups.service** - this runs [wal-e](https://github.com/wal-e/wal-e) to backup our database to our S3 object store. This is a "oneshot" systemd service, so it is not enabled.
* **postgres-backups.timer** - this is a timer to run postgres-backups.service overnight.
* **postgres-restore.service**  - this runs [wal-e](https://github.com/wal-e/wal-e) to restore our database from the latest backup in our S3 object store. This is a "oneshot" systemd service, so it is not enabled. Run it only when you need to.
* **ims-deploy.service** - this runs the Djano "migrate" and "collectstatic" commands to update ims to the latest version. It is a "oneshot" systemd service, not enabled. It is run by the ims.yml playbook whenever IMS is updated to the latest version.

###2. Bastion

* **nginx.service** - starts the [nginx](https://nginx.org/en/) webserver. This is enabled so it starts on boot. The webserver directs traffic to the other VMs: ims, ims_staging and tracker.

###3. Tracker

* **tracker-webserver.service** - starts the tracker's webserver. Enabled so it starts up on boot.
* **mongodb.service** - starts up [mongodb](https://www.mongodb.com/) which is used by the data tracker. Enabled so it starts up on boot.
* **mongodb-backups-s3.service** - this runs [mongodump](https://docs.mongodb.com/v3.2/reference/program/mongodump/) to dump the mongodb database and save it to our S3 object store. It is a "oneshot" systemd service, so not enabled.
* **mongodb-backups.timer** - this is a timer to run mongodb-backups-s3.service overnight.
* **mongodb-restore.service** - this fetches the latest mongodb dump from our S3 object store and restores it using [mongorestore](https://docs.mongodb.com/manual/reference/program/mongorestore/) to restore it. It is not enabled. Run it only when you need to.
* **tracker.service** - this runs the perl script that analyses ims, hpscreg, ecacc etc. and loads its findings into mongodb.
* **tracker.timer** - this is a timer to run tracker.service twice per day.


