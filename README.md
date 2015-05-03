# Ubuntu 14.04 LTS basesystem

Basic salt states that I deploy on every server I manage.

Idea is to have a workspace that’s as close as possible to what every server is running
so that we can use it in production, but also use it for local development.



## Features

## Use as part of production deployment

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



## Use as a local workspace

Files in `salt/` is used **only** for Vagrant development.
This workspace is setup to be used as a local workbench,
if you want anything outside the scope of what you want on EVERY servers;
make it a separate state formula :)

If you already have [Vagrant installed].

```
vagrant up
```

Note that the Vagrantfile don’t automatically call `highstate`.
That’s because I frequently delete VMs and I’d rather have the VM being build
while I scratch my state formula prototype.

To use the base system, you´ll have then to;

```
vagrant ssh
sudo salt-call state.highstate
```

