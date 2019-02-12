SSH into your vm
================

Are you sure you need to ssh to the vm?
Please avoid changing configuration when you ssh into the VMs. It is better to change the ansible configuration and then run ansible to do the update.
Otherwise your change will not be persistent.

SSH keys
--------

You will need ssh keys set up. There are no passwords.
Add your authorized_keys file with the name of the username you want to use
in the folder [authorized_keys](../authorized_keys) in this repo.
This username needs to be in server_admins in [group_vars](../group_vars/all.yml)
to get access for ansible and sudo.

You'll need to find an exsting server admin who has ssh keys already set up and ask them to run the playbooks for you.
