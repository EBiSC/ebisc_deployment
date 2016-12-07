Embassy
=======

[Embassy](http://www.embassycloud.org/) is an [OpenStack](https://www.openstack.org/)-based private cloud hosted by EMBL-EBI. 
EBiSC is a tenant of Embassy. This means we have quotas of cloud resources with which we can launch virtual machines to deploy the IMS.

The Embassy cloud workspace is at [https://extcloud03.ebi.ac.uk](https://extcloud03.ebi.ac.uk). You will need a personal user account and password.

Our virtual infrastructure
--------------------------

####Compute

We have been allocated 8 cores total.  We use a 2-cpu VM for IMS, a 2-cpu VM for the data tracker, a 2-cpu VM for ims-staging, and a 1-core VM for the bastion.

####IP addresses

We have been allocated one floating IP (193.62.54.96). This is the public address for all our services (IMS, staging, and tracker).
Therefore, we deploy a [bastion host](https://en.wikipedia.org/wiki/Bastion_host) with the floating IP, and this is
the only VM which is directly accessible from the outside world.
The bastion host runs a proxy nginx server for connections to IMS, staging IMS etc.
To access any VM by ssh, you must tunnel through the bastion host.

####Persistent disk

We have a quota of ??? GB of block storage. See [openstack cinder]().

Our VMs can mount volumes of block storage.  This means when a VM is terminated and restarted, we do not lose the data on the volume.
It has the added advantage of 7 daily snapshots.

However, *we must not rely on these snapshots* as a backup, because they are not saved externally from the cloud infrastructure.

####Object stores

This is what we use to backup data. Embassy cloud has two object stores: one is [Amazon S3](???) compatible; the other is [swift](???) compatible.

We use the object store for backing up databases and important files (e.g. CofAs).
