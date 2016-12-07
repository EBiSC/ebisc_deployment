SSH into your vm
================

Are you sure you need to ssh to the vm?
Please avoid changing configuration when you ssh into the VMs. It is better to change the ansible configuration and then run ansible to do the update.
Otherwise your change will not be persistent.

Bastion
-------

Our public ip is 193.62.54.96.  You can connect directly to the bastion as user "core":

    ssh core@193.62.54.96

Other VMs
---------

To ssh into any other vm you must tunnel through the bastion.
First go to [the embassy dashboard](https://extcloud03.ebi.ac.uk) and note
down the private ip of the vm you are aiming for. If the private ip address is 192.168.0.10 then
then the ssh command you need is this:

    ssh -o ForwardAgent=yes -o ProxyCommand="ssh -W %h:%p -q core@193.62.54.96" core@192.168.0.10

SSH keys
--------

You will need ssh keys set up. There are no passwords.
Add your ssh key to the file [group_vars/all.yml](../group_vars/all.yml) in this repo.
Then run the ansible playbooks to copy the keys to each VM.
Actually, you'll need to find a friend who has ssh keys already set up and ask them to run the playbooks for you.
