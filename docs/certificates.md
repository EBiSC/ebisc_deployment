I followed [instructions from coreos](https://github.com/coreos/docs/blob/e9359bb91a8b243ef8b17623b211a91fcd8e2ec9/os/generate-self-signed-certificates.md)
to generate certifcates for TLS communication between VMs.

    cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server.json | cfssljson -bare server

The public keys generated are in the [files/tls](../files/tls) directory.
The private keys are encrypted again using [ansible vault](http://docs.ansible.com/ansible/playbooks_vault.html) and put in "secrets.yml" files in
the [group_vars](../group_vars) directory. The password to decrypt the ansible-vault files is kept in confluence.
