I followed [instructions from coreos](https://github.com/coreos/etcd/tree/master/hack/tls-setup)
to generate certifcates for TLS communication between VMs.

  git clone https://github.com/coreos/etcd.git
  cd etcd/hack/tls-setup
  vi config/req-csr.json
  # {{ edit config/req-csr.json to have all local ip }}
  make

The public keys generated are in the [files/etcd-tls](../files/etcd-tls) directory.
The private keys are encrypted again using [ansible vault](http://docs.ansible.com/ansible/playbooks_vault.html) and put in "secrets.yml" files in
the [group_vars](../group_vars) directory. The password to decrypt the ansible-vault files is kept in confluence.
