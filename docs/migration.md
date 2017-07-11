
### Create a new branch of ebisc_deployment

Make the following changes in the new branch

1. make new embassy-openrc.sh
  * You can download rc files from the API access tab of [your cloud dashboard](https://extcloud06.ebi.ac.uk/dashboard/project/api_access/)
  * Which version? Don't know. Previously we used v2.0 because that's all that was available.
2. edit:
  * file: `roles/tracker/files/mongodb-backups-s3.service`
  * from: `AWS_PREFIX=tracker_mongodb`
  * to:   `AWS_PREFIX=tracker06_mongodb` <--- please suggest sensible name structure!
3. edit:
  * file: `roles/ims/templates/postgres-backups.service.j2`
  * from: `-e WALE_S3_PREFIX=s3://${AWS_BUCKET}/{{ vm }}-postgres/pgsql`
  * to:   `-e WALE_S3_PREFIX=s3://${AWS_BUCKET}/{{ vm }}06-postgres/pgsql`
4. edit:
  * file: `roles/ims/templates/ims-postgres.service.j2`
  * from: `-e WALE_S3_PREFIX=s3://${AWS_BUCKET}/{{ vm }}-postgres/pgsql`
  * to:   `-e WALE_S3_PREFIX=s3://${AWS_BUCKET}/{{ vm }}06-postgres/pgsql`
    
5. edit:
  * file: `roles/ims/templates/duplicity.service.j2`
  * from: `-e AWS_PREFIX={{ vm }}-media`
  * to:   `-e AWS_PREFIX={{ vm }}06-media`

### Run playbooks using the new branch

I hope [the Ansible documentation](./ansible.md) will guide you running the correct playbooks in the correct order.

These are the interesting ones:

* ims-restore.yml
* tracker-restore.yml

We will use the \*-restore.yml playbooks to pull the **old** objects from the object storeand load them into the vm.


### Copy certificates from the old bastion to the new bastion

On your local machine (check you understand this command first):
```
ssh core@193.62.54.96 sudo tar -cz -C /var/projects/ebisc -f - letsencrypt | ssh core@{{NEW_IP}} tar -xz -C /var/projects/ebisc -f -
```

Then ssh into the new bastion and restart nginx service. Can you work out how to do this using [the ssh docs](./ssh.md) and [the vm configuration docs](./vm_configuration.md)?

### Is everything working OK?

Do you know how to look at the **new** versions of cells.ebisc.org, cells-staging.ebisc.org and www.funwithipsc.top in your browser?

Clue: you have to edit `/etc/hosts` on your local computer.

### When we're ready to migrate...

We told Rachel and Gregory we would do this week starting 24th July.

1. ask Roslin to stop editing on website
2. run the restore playbooks again
3. possibly copy the certificates again, as above
4. ask Gregory to update DNS.
5. wait 3600 seconds (test - how do I know this?)
6. Roslin can start editing website again.


### Post migration tidy-up

#### Delete the old objects from the object store

First, ssh into tracker (new or old)

Then manually start a docker container. You should do it this way because the tracker's mongodb-backups-s3 image has the aws cli installed
```
/usr/bin/docker run --rm -it --read-only --cap-drop=all -e AWS_ACCESS_KEY_ID=DuiolYQGNGoAxNyYQMun -e AWS_SECRET_ACCESS_KEY=7oplw6CRT9gbvXwGtku2ZMrhk6DGpAqfrc15xVsC ebisc/mongodb-backups-s3 /bin/bash
```

Now use the aws cli from within the docker container
```
aws --endpoint-url=https://s3.embassy.ebi.ac.uk s3 ls s3://ebisc/
```

#### Tidy up in git

Do this in your migration branch

1. edit:
  * file: `roles/ims/templates/postgres-restore.service.j2`
  * from: `-e WALE_S3_PREFIX=s3://${AWS_BUCKET}/ims-postgres/pgsql`
  * to:   `-e WALE_S3_PREFIX=s3://${AWS_BUCKET}/ims06-postgres/pgsql`
2. edit:
  * file: `roles/ims/templates/duplicity-restore.service.j2`
  * from: `-e AWS_PREFIX=ims-media`
  * to:   `-e AWS_PREFIX=ims06-media`
3. edit:
  * All documentation that has our floating IP

Finally merge the migration branch into master

