# Base system salt state

[WebPlatform][wpd] infrastructure servers runs on the same GNU/Linux distribution; *Ubuntu Linux 14.04 LTS*.
This *salt state* formula is meant to be applied to **every** server and containers we run.

Idea is to have a workspace that’s as close as possible to what every server/container we’re running.



## Features

* system user "**webapps**" who can be used as owner for running processes
* "lazy" shell aliases, start typing "lazy-" and you’ll get a few complex commands available
* **Installs** utility packages:
 * screen, tmux
 * htop
 * monkeytail (i.e. tail all caching logs using `mtail @caching`)
* **Removes** non needed default packages typically installed on a base image
 * landscape
 * avahi
 * whoopsie
* **Ensures security updates are applied automatically**



## Use

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
The other folders are workspace helpers.

  [wpd]: https://www.webplatform.org/
