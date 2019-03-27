---
title: "Vagrant Commands"
permalink: /commands/vagrant/
toc: true
---

## Add a box from local path

`vagrant box add --name BOXNAME C:\Packer\Artifacts\Path\To\BOXNAME.box`

## List boxes

`vagrant box list`

## Remove boxes

`vagrant box remove BOXNAME`

`vagrant box remove windows_2012_r2_virtualbox`

## Initialize the current directory to be a Vagrant environment

`vagrant init BOXNAME`

`vagrant init windows_2012_r2_virtualbox`

## Show status of current box from within it's containing folder

`vagrant status`

## Show status of ALL boxes

`vagrant global-status`

## Remove stale boxes from cache, then Show status of ALL remaining boxes

`vagrant global-status --prune`

## Snapshots

### List Snapshots

`vagrant snapshot list`

### Create a Snapshot

`vagrant snapshot save SNAPSHOTNAME`

`vagrant snapshot save snapshot01`

### Restore a Snapshot

`vagrant snapshot restore SNAPSHOTNAME`

`vagrant snapshot restore snapshot01`

### Delete a Snapshot

`vagrant snapshot delete SNAPSHOTNAME`

`vagrant snapshot delete snapshot01`

## Delete VM

Use the VMID found by running `vagrant global-status`:

`vagrant destroy VMID`

`vagrant destroy 95053ca`

## Show open ports

`vagrant port`

## Reload vagrantfile config

Use after updating port mapping:

`vagrant reload`

## Show VirtualBox GUI Console

<pre>
config.vm.provider :virtualbox do |v, override|`
        <b>v.gui = true</b>
</pre>

## Forward a port from host to guest

This example is for RDP port 3389:

`config.vm.network "forwarded_port", guest: GUESTPORT, host: HOSTPORT`

`config.vm.network "forwarded_port", guest: 3389, host: 33389`

## Vagrant Help

```code
> vagrant -h
Usage: vagrant [options] <command> [<args>]

    -v, --version                    Print the version and exit.
    -h, --help                       Print this help.

Common commands:
     box             manages boxes: installation, removal, etc.
     connect         connect to a remotely shared Vagrant environment
     destroy         stops and deletes all traces of the vagrant machine
     global-status   outputs status Vagrant environments for this user
     halt            stops the vagrant machine
     help            shows the help for a subcommand
     init            initializes a new Vagrant environment by creating a Vagrantfile
     login           log in to HashiCorp's Vagrant Cloud
     package         packages a running vagrant environment into a box
     plugin          manages plugins: install, uninstall, update, etc.
     port            displays information about guest port mappings
     powershell      connects to machine via powershell remoting
     provision       provisions the vagrant machine
     push            deploys code in this environment to a configured destination
     rdp             connects to machine via RDP
     reload          restarts vagrant machine, loads new Vagrantfile configuration
     resume          resume a suspended vagrant machine
     share           share your Vagrant environment with anyone in the world
     snapshot        manages snapshots: saving, restoring, etc.
     ssh             connects to machine via SSH
     ssh-config      outputs OpenSSH valid configuration to connect to the machine
     status          outputs status of the vagrant machine
     suspend         suspends the machine
     up              starts and provisions the vagrant environment
     validate        validates the Vagrantfile
     version         prints current and latest Vagrant version

For help on any individual command run `vagrant COMMAND -h`

Additional subcommands are available, but are either more advanced
or not commonly used. To see all subcommands, run the command
`vagrant list-commands`.
```
