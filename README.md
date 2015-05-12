# Ubuntu 14.04 LTS basesystem

Basic salt states that I deploy on every server I manage.

Idea is to have a workspace that’s as close as possible to what every server is running
so that we can use it in production, but also use it for local development.



## Features

### Use as part of production deployment

Pull this repository in your servers.


```yaml
# /etc/salt/minion.d/roots.conf

fileserver_backend:
  - roots
  - git

gitfs_provider: gitpython

gitfs_remotes:
  - https://github.com/renoirb/salt-basesystem.git
```

Then add it to your server `top.sls` file.

```
# /srv/salt/top.sls
base:
  '*':
    - basesystem
```

Notice that only what’s in `basesystem/` will be used.
The other folders are workspace helpers
so you can *also* use this repository as a local workspace too.



### Use as a local workspace

This repository can also be used as a local salt workbench.

In other words, you can use this to have a local Vagrant VM with anything
you set in your servers, and use it in production as a `gitfs` formula.

While its useful to have a base system AND a workspace; make sure you don’t mix
your service from what you have everywhere.

Files in `salt/` is used **only** for Vagrant development.

This workspace is setup to be used as a local workbench,
if you want anything outside the scope of what you want on EVERY servers;
make it a separate state formula :)

If you already have [Vagrant installed](https://www.vagrantup.com/) installed.

Add the following plugins.

```
vagrant plugin install vagrant-salt
vagrant plugin install vagrant-vbguest

```

**NOTE** Only `vagrant-salt` is mandatory.

Then, launch the VM:

```
vagrant up
```

Notice that the Vagrantfile don’t automatically call `highstate`.
That’s because I frequently delete VMs and I’d rather have the VM being build
while I scratch my state formula prototype.

To use the base system, you´ll have then to;

```
vagrant ssh
sudo salt-call state.highstate
```



### Vagrant Sandbox utilities

#### Use alongside with Docker

If your system uses Docker to run containers, you can use the [docker-formula](https://github.com/saltstack-formulas/docker-formula) on your servers
but also you could need it while working on your vagrant box.

Notice that if you’re using Mac OS X and use Docker, you are most likely using [*boot2docker*](http://boot2docker.io/);
which is basically what this is about. The difference here is that we want to run containers in the same way we would in production.

To use Vagrant within your Vagrant sandbox, make sure you first ran [local workspace sandbox](#Use as a local workspace), then;

```
sudo salt-call state.sls vagrantsandbox.docker
```

Since this will add kernel modules, you’ll have to reboot the Vagrant box.

Once rebooted;

Check if you have `aufs` enabled;

```
docker -D info
...
Storage Driver: aufs
...
```

Then you can play with Docker.

```
docker pull ubuntu:trusty
docker run -i -t ubuntu:trusty /bin/bash
```

You’re now inside a Vagrant VM, *inside* a Docker container!

```
root@e3a7be5a2d3b:/# ps
PID TTY   TIME      CMD
  1 ?     00:00:00  bash
 17 ?     00:00:00  ps
```
