Etcd2 servers are set up by Ansible.

1. When setting up a new cluster it will launch etcd servers with names like etcd-worker-\* and [proxy servers](https://coreos.com/etcd/docs/latest/proxy.html)
  with names like proxy-worker-\*

2. When a cluster already exists, it will only start proxy workers, not etcd servers.  [Follow the coreos instructions](https://coreos.com/etcd/docs/latest/proxy.html) if you want to turn a proxy worker into a etcd server.
