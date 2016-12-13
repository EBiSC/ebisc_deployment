FAQ
===

####What does this error message mean?

``ERROR! The file inventory/openstack.py is marked as executable, but failed to execute correctly.....``

You see this error message if your openstack environment variables are not set properly. Try sourcing ``source embassy-openrc.sh``.

###And this one?

``ERROR! Decryption failed``

You see this error message if you are running an ansible playbook without passing in the ansible-vault password.  [Read this documentation](http://docs.ansible.com/ansible/playbooks_vault.html#running-a-playbook-with-vault)
to find out how to pass in the password.

####How do I deploy a new version of IMS?

Do a ``git push`` to push your updates to the ims git repo. Then run the ims playbook:

    ansible-playbook --limit=ims --tags=deploy ims.yml

This triggers a ``git pull`` on the remote vm. It will build a new docker image and then restart the uwsgi container.

####How do I restore IMS after a complete failure?

Run the launch_cloud.yml playbook to start up the VM:

    ansible-playbook launch_cloud.yml

Run the ims.yml playbook to configure the ims VM, including building all docker containers and starting all services.

    ansible-playbook --limit=ims ims.yml

If IMS is still missing data, then restore it from the S3 object store:

    ansible-playbook --limit=ims ims-restore.yml

###How do I sync IMS staging from IMS?

Use the ims-restore.yml playbook to "restore" files onto ims_staging using the backups in the S3 object store.

    ansible-playbook --limit=ims_staging ims-restore.yml

###How do I deploy a new version of the tracker?

Do a ``git push`` to push your updates to the tracker git repo. Then run the tracker playbook:

    ansible-playbook tracker.yml

This triggers a ``git pull`` on the remote vm. It will build a new docker image and then restart the webserver container.

####How do I restore the tracker after a complete failure?

Run the launch_cloud.yml playbook to start up the VM:

    ansible-playbook launch_cloud.yml

Run the tracker.yml playbook to configure the tracker VM, including building all docker containers and starting all services.

    ansible-playbook tracker.yml

If the tracker is still missing data, then restore it from the S3 object store:

    ansible-playbook tracker-restore.yml
