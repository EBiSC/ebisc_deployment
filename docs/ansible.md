Ansible
=======

[Ansible](https://www.ansible.com/) is software for configuring remote machines over ssh. We use ansible to configure our cloud, to launch VMs,
to install and configure software on VMs. The Ansible [documentation](http://docs.ansible.com/ansible/index.html) is very comprehensive.

Ansible is idempotent, which means you can safely run ansible tasks over and over again, without changing the system.
You could set up the entire cloud from scratch by running our ansible playbooks - this will launch and configure all VMs.
Alternatively, you could run our ansible playbooks on an existing cloud setup, and it will update the system only where necessary.

Setup to use this repo
========================

You must have python and pip installed on your local machine.

Check your private key is in group_vars/all.yml. These keys are copied onto the VMs, so only these users can ssh in.

Ansible Vault
=============

[Ansible vault](http://docs.ansible.com/ansible/playbooks_vault.html) is a feature allows keeping sensitive data such as passwords and keys. We encrypt our secrets with ansible vault, which means it is safe to keep the encrypted files in source control.

This means you need the password before you can run the ansible playbooks.  The [Ansible vault documentation](http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault) describes how to pass the password on the command line.
The rest of this documentation assumes you have the ``ANSIBLE_VAULT_PASSWORD_FILE`` environment set, as described in the [vault documentation](http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault).

Playbooks
=========

You should run all of these commands from your local machine. Ansible is "idempotent" which means it is safe to run the commands over and over again.

## 1. ims.yml

    ansible-playbook ims.yml

The playbook IMS.yml configures instances of the IMS server. You can use the ``--limit`` flag to limit to a specific host (ebisc-ims or local-dev).

    ansible-playbook ims.yml -l local-dev
    ansible-playbook ims.yml -l ebisc-ims

You would run this playbook to congigure ims for the first time. You would also run it to do a deployment of the latest version of ims.

Here are some of the things that happen when you run this playbook:

* Adds everybody's ssh key to the remote vm.
* Creates systemd unit files (e.g. for running postgres, elasticsearch, nginx, backup jobs etc.)
* Git pull to get the latest version of the ims and tracker code
* Builds all docker images
* Restarts and enables all docker images

## 2. ims-dump.yml

    ansible-playbook ims-dump.yml

This playbook does two things:

* Takes a dump of the postgres database and copies it to your local machine.
* Synchronizes the media files and copies them to your local machine

To do just one or the other you could use the ``--tags`` option on the command line:
    ansible-playbook ims-dump.yml -t database
    ansible-playbook ims-dump.yml -t media

This playbook is to help you in development. Once you have copied the database and media files to your local machine then you
can run IMS locally.

## 3. ims-restore.yml

This command will push a local backup (see above) to an IMS instance:

    ansible-playbook ims-restore.yml --limit=local-dev

You can use ``--tags=database`` option to restore just the database or ``--tags=media`` to just restore the media files.
For example:

    ansible-playbook --limit=ebisc-ims --tags=media ims-restore.yml
