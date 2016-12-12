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

    pip install ansible shade

Source your environment variables from embassy-openrc.sh. This enables you to interact with Embassy from your local machine over the openstack API. To do this you must have a admin username and password for the EBiSC project in Embassy.

    source embassy-openrc.sh

Install the ansible modules listed in ansible-requirements.yml. These are some third-party modules which we use to configure our VMs:

    ansible-galaxy install -r ansible-requirements.yml -p vendor/

Download the openstack.py inventory file and put it in your inventory directory. This inventory file tells ansible how to find information about VMs on openstack.

    curl -L https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/openstack.py > inventory/openstack.py
    chmod +x openstack.py

Check your private key is in group_vars/all.yml. These keys are copied onto the VMs, so only these users can ssh in.

Check you have a key on your local machine that gives you access to the git repo at https://github.com/DouglasConnect/ebisc. The remote VM will use your local private key to access github.

Playbooks
=========

1. IMS.yml
----------

The playbook IMS.yml configures 
