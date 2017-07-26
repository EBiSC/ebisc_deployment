# Deploy on AWS

It is [my opinion](https://github.com/istreeter) that we should not have deployed IMS on Embassy. This document explains how I would have used the AWS platform as an alternative.

A summary of reasons why AWS would be a better solution:

* AWS has a [managed PostgreSQL service](https://aws.amazon.com/rds/) with [backups](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html), but on Embassy we had to manage our own
* AWS has a [serverless compute service](https://aws.amazon.com/lambda/), but Embassy only has full VMs
* AWS has a [managed Elasticsearch service](https://aws.amazon.com/elasticsearch-service/)

In combination, this would mean a much simpler deployment. No need for nginx, no bastion server, no need for docker or coreos, no need for systemd unit files, no need for postgreSQL backups or static file backup....

## How To

I would deploy the Django application on AWS as a [lambda function](https://aws.amazon.com/lambda/). This is code that runs without a dedicated server. You just upload the code to AWS and it gets run every time there is an incoming http request.
This means we avoid the overhead costs of VM maintainence. There is no VM downtime, there are fewer security issues compared to a VM, and the service should scale better. Plus you only pay for what you use; you do not pay for a 24/7 running VM.

[Api Gateway](https://aws.amazon.com/api-gateway/) is the service that routes incoming http requests to the Lambda function (the Django app).

[Zappa](https://github.com/Miserlou/Zappa) is the code I would use to set up AWS Lamda and the API Gateway. The [Zappa documentation](https://github.com/Miserlou/Zappa) is excellent and explains exactly how to use it.
Zappa handles letsencrypt certificates, and [auto-renewing certificates](https://github.com/Miserlou/Zappa/blob/master/docs/domain_with_free_ssl_dns.md).
Also look at zappa's scheduling - which will be used to run IMS nightly updates.

The app's static files (e.g. html,css,js) and media files (CofA, cell images) would get served from [AWS S3 object store](https://aws.amazon.com/s3/).
This also takes care of backing up our important files.
This [blog post](https://www.caktusgroup.com/blog/2014/11/10/Using-Amazon-S3-to-store-your-Django-sites-static-and-media-files/) explains exactly how to do this with a Django application.
It uses the [django-storages](http://django-storages.readthedocs.org/en/latest/) package which itegrates S3 with Django.

AWS provides a [managed PostgreSQL service](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html).
It supports [backups and rolling back to a point in time](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PIT.html).
We would set up a DB instance and then configure the Django app to use the new instance. 

We would also set up an instance of the AWS [Elasticsearch service](https://aws.amazon.com/elasticsearch-service/) and configure the Django app to use this instance.

You could still use Ansible to set up our resources, e.g. this module to create the database: http://docs.ansible.com/ansible/latest/rds_module.html

## Pricing approximate estimates on AWS

Lambda: Free, assuming <1million requests per month.  Plus $0.00001667 per GB-second of compute.  This cost is essentially nothing.

API gateway: $3.50 per million API calls + $0.09/GB data transfer. This cost is essentially nothing.

Postgres: $12.41 monthly for a reserved 1 year db.t2.micro + data transfer (negligible)

Elasticsearch: 0.021 per hour = $15.21 monthly

S3 (storage for static files): 0.116 per GB-month = ~$0.25 per month for our current usage
