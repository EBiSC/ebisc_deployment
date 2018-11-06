Ansible
=======

[Ansible](https://www.ansible.com/) is software for configuring remote machines over ssh. We use ansible to configure our cloud, to launch VMs,
to install and configure software on VMs. The Ansible [documentation](http://docs.ansible.com/ansible/index.html) is very comprehensive.

Ansible is idempotent, which means you can safely run ansible tasks over and over again, without changing the system.
You could set up the entire cloud from scratch by running our ansible playbooks - this will launch and configure all VMs.
Alternatively, you could run our ansible playbooks on an existing cloud setup, and it will update the system only where necessary.

Setup to use this repo
========================

You must have python and pip installed on your local machine. Next, install the following dependencies on your local machine:

    pip install ansible openstacksdk

Source your environment variables from embassy-openrc.sh. This enables you to interact with Embassy from your local machine over the openstack API. To do this you must have a admin username and password for the EBiSC project in Embassy.

    source embassy-openrc.sh

Install the ansible modules listed in ansible-requirements.yml. These are some third-party modules which we use to configure our VMs:

    ansible-galaxy install -r ansible-requirements.yml -p vendor/

Download the openstack_inventory.py file and put it in your inventory directory. This inventory file tells ansible how to find information about VMs on openstack.

    curl -L https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack_inventory.py > inventory/openstack_inventory.py
    chmod +x inventory/openstack_inventory.py

Check your private key is in group_vars/all.yml. These keys are copied onto the VMs, so only these users can ssh in.

Check you have a key on your local machine that gives you access to the git repo at https://github.com/DouglasConnect/ebisc. The remote VM will use your local private key to access github.

Ansible Vault
=============

[Ansible vault](http://docs.ansible.com/ansible/playbooks_vault.html) is a feature allows keeping sensitive data such as passwords and keys. We encrypt our secrets with ansible vault, which means it is safe to keep the encrypted files in source control.

This means you need the password before you can run the ansible playbooks.  The [Ansible vault documentation](http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault) describes how to pass the password on the command line.
The rest of this documentation assumes you have the ``ANSIBLE_VAULT_PASSWORD_FILE`` environment set, as described in the [vault documentation](http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault).

Playbooks
=========

You should run all of these commands from your local machine. Ansible is "idempotent" which means it is safe to run the commands over and over again.

## 1. launch_cloud.yml

    ansible-playbook launch_cloud.yml

This playbook uses openstack modules to launch our cloud virtual infrastructure, such as the network, security groups, VMs, persistent volumes etc.  If you were starting up the cloud from scratch then you would run this playbook first before running any other playbook.

## 2. ims.yml

    ansible-playbook ims.yml

The playbook IMS.yml configures both the production and staging instances of the IMS. You could also use the ``--limit`` flag to configure the production and staging instsances independently.

    ansible-playbook --limit=ims ims.yml
    ansible-playbook --limit=ims_staging ims.yml

You would run this playbook to congigure ims for the first time. You would also run it to do a deployment of the latest version of ims.

Here are some of the things that happen when you run this playbook:

* Adds everybody's ssh key to the remote vm.
* Mounts the persistent disk and formats it if neeeded.
* Creates systemd unit files (e.g. for running postgres, elasticsearch, nginx, backup jobs etc.)
* Git pull to get the latest version of the ims code
* Builds all docker images
* Restarts and enables all docker images

## 3. tracker.yml

    ansible-playbook tracker.yml

You would run this playbook to congigure the data tracker for the first time.
You would also run it to do a deployment of the latest version of the tracker.

Here are some of the things that happen when you run this playbook:

* Adds everybody's ssh key to the remote vm.
* Mounts the persistent disk and formats it if neeeded.
* Creates systemd unit files (e.g. for running mongodb, webserver, daily tracking jobs, backup jobs etc.)
* Git pull to get the latest version of the tracker code
* Builds all docker images
* Restarts and enables all docker images

## 4. bastion.yml

    ansible-playbook bastion.yml

You would run this playbook to congigure the bastion for the first time. The bastion is the VM responsible for routing
traffic to the other VMs (ims, staging, tracker). You must re-run this playbook if you ever re-launch one of the other VMs (ims, staging, or tracker).
This is because the private IP addresses of the VMs change when you relaunch them, and bastion needs to be reconfigured with the new IP addresses.

Here are some of the things that happen when you run this playbook:

* Adds everybody's ssh key to the remote vm.
* Copies over TLS certificates
* Creates a systemd unit file for running nginx as a reverse proxy
* Creates a nginx configuration file with IP addresses of the other VMs
* Builds the nginx docker image
* Restarts and enables nginx

## 5. tracker-restore.yml

    ansible-playbook tracker-restore.yml

This playbook is for recovering from a failure. Assume something bad has happened and you have lost
the tracker VM and the tracker's persistent disk.  First you would run tracker.yml to restart the data tracker. But the tracker's
database will still be empty.  Luckily the database is backed up in the S3 object store.

This playbook pulls the latest backup from the object store and loads it into the database.

## 6. ims-dump.yml

    ansible-playbook ims-dump.yml

This playbook does two things:

* Takes a dump of the postgres database and copies it to your local machine.
* Makes a tarball of the media files and copies them to your local machine

To do just one or the other you could use the ``--tags`` option on the command line:
    ansible-playbook --tags=database ims-dump.yml
    ansible-playbook --tags=media ims-dump.yml

This playbook is to help you in development. Once you have copied the database and media files to your local machine then you
can run IMS locally.

## 7. ims-restore.yml

This command will recover IMS after a failure:

    ansible-playbook --limit=ims ims-restore.yml

Assume something bad has happened and you have lost
the IMS VM and the IMS's persistent disk.  First you would run ims.yml to restart ims. But the ims's
database will still be empty and you will be missing all the media files (CofAs etc).
Luckily the database and media files are backed up in the S3 object store.

This playbook is also used for syncing ims to ims_staging.  You would run this command:

    ansible-playbook --limit=ims_staging ims-restore.yml

The above command works because IMS regularly backs up to S3 but ims_staging doesn't ever do backups. So doing a restore 
on ims_staging will pull backups from IMS production.

This playbook does two things:

* Fetches the latest database backup from the S3 object store and loads it into the database
* Fetches the latest media files backup from S3 and restores it to the /mnt/cinder1/media directory

The playbook restores both ims and ims_staging.
You could use ``--limit=ims`` to just restore to ims, or ``--limit=ims_staging`` to just restore to ims_staging.
You could use ``--tags=database`` option to restore just the database or ``--tags=media`` to just restore the media files.
For example:

    ansible-playbook --limit=ims --tags=media ims-restore.yml
