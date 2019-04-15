Creating a VM with Packer
=========================

[Packer](https://packer.io) is a tool to build (virtual) machines
with simple scripts, without the need to download pre-made
machines including virtual hard drive files.
We use it to build a VirtualBox VM given a link of an official Ubuntu installer iso.

You need to install packer and [VirtualBox](https://www.virtualbox.org/).
Then:

    cp create_local-dev.sh.example create_local-dev.sh
    chmod a+x create_local-dev.sh
    ./create_local-dev.sh

You can edit ``create_local-dev.sh`` before to set a name in VirtualBox.
The machine is registered in VirtualBox and one way to start is in the GUI when starting ``virtualbox``.

You can either use port forwarding (settings-\>network-\>adapter 1-\>advanced)
or change the Adapter to host-only or bridged network).
Once you know what IP/port you can use to connect,
you can use ``ssh-copy-id`` to push your SSH key and setup local-dev with:

    cp inventory/local.example inventory/local

and editing inventory/local for your setup.
