FAQ
===

#### What does this error message mean?

If you see either of the following error messages....

    ERROR! The file inventory/openstack.py is marked as executable, but failed to execute correctly.....

or

    ERROR! Attempted to execute "openstack.py" as inventory script: Inventory script (openstack.py) had an execution error: Error fetching server list on envvars:RegionOne:

...then it means your openstack environment variables are not set properly. Try sourcing ``source embassy-openrc.sh``.  Double check you are typing in the correct username and password.

#### And this one?

``ERROR! Decryption failed``

You see this error message if you are running an ansible playbook without passing in the ansible-vault password.  [Read this documentation](http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault)
to find out how to pass in the password.

#### How do I deploy a new version of IMS?

Do a ``git push`` to push your updates to the ims git repo. Then run the ims playbook:

    ansible-playbook --limit=ims --tags=deploy ims.yml

This triggers a ``git pull`` on the remote vm. It will build a new docker image and then restart the uwsgi container.

#### How do I restore IMS after a complete failure?

Run the launch_cloud.yml playbook to start up the VM:

    ansible-playbook launch_cloud.yml

Run the ims.yml playbook to configure the ims VM, including building all docker containers and starting all services.

    ansible-playbook --limit=ims ims.yml

If IMS is still missing data, then restore it from the S3 object store:

    ansible-playbook --limit=ims ims-restore.yml

#### How do I sync IMS staging from IMS?

Use the ims-restore.yml playbook to "restore" files onto ims_staging using the backups in the S3 object store.

    ansible-playbook --limit=ims_staging ims-restore.yml

#### How do I deploy a new version of the tracker?

Do a ``git push`` to push your updates to the tracker git repo. Then run the tracker playbook:

    ansible-playbook tracker.yml

This triggers a ``git pull`` on the remote vm. It will build a new docker image and then restart the webserver container.

#### How do I restore the tracker after a complete failure?

Run the launch_cloud.yml playbook to start up the VM:

    ansible-playbook launch_cloud.yml

Run the tracker.yml playbook to configure the tracker VM, including building all docker containers and starting all services.

    ansible-playbook tracker.yml

If the tracker is still missing data, then restore it from the S3 object store:

    ansible-playbook tracker-restore.yml

#### Why do I see failed sshd units when I ssh into bastion?

It is OK to ignore these failed units. This is what I see when I ssh into the bastion vm:

    $ ssh core@193.62.52.148
    Last login: Wed Mar 15 11:22:04 UTC 2017 from 193.63.221.99 on ssh
    Container Linux by CoreOS stable (1298.5.0)
    Failed Units: 4
      sshd@88-192.168.0.100:22-111.73.45.208:4349.service
      sshd@89-192.168.0.100:22-111.73.45.208:2605.service
      sshd@90-192.168.0.100:22-111.73.45.208:3462.service
      sshd@91-192.168.0.100:22-111.73.45.208:3081.service

This happens when somebody (possibly us, or possibly a bad person) tried to login via ssh, and the ssh daemon failed.
We have noticed that somebody (bad person) is continually trying to ssh to bastion every one second.
It is acceptable for the ssh daemon to have a small number of safe fails given this level of attempted connections.

You could clear them like this: ``sudo systemctl reset-failed``

#### IMS ansible-playbook fails to authenticate your ssh key for the IMS git repository and perform a git pull

This can be caused by a number of problems.

On a Mac one issue might be that your ssh key is not loaded automatically so cannot be forwarded.

Edit ~/.ssh/config to contain:
Host *
    UseKeychain yes

Then add your private ssh key to your keychain: /usr/bin/ssh-add -K /path/to/private_key (e.g. /usr/bin/ssh-add -K ~/.ssh/id_rsa)

Also ensure that you have stored the Ansible vault password (e.g. ANSIBLE_VAULT_PASSWORD_FILE=~/.ansible_vault_pass.txt)

Another possible issue could be that you forgot to associate your public ssh key with your github account. 

You can follow this article to add your public key to github https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/

Other issues can be explored at https://developer.github.com/guides/using-ssh-agent-forwarding/

#### How to edit secrets files
Reference to the [ansible documentation](http://docs.ansible.com/ansible/playbooks_vault.html#editing-encrypted-files)  
