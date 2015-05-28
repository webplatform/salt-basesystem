# Base system salt state

[WebPlatform][wpd] infrastructure servers runs on the same GNU/Linux distribution; *Ubuntu Linux 14.04 LTS*.
This *salt state* formula is meant to be applied to **every** server and containers we run.

Idea is to have a workspace that’s as close as possible to what every server/container we’re running.



## Features

* system user "**webapps**" who can be used as owner for running processes
* [Macros](#Macros):
 * to [clone a git repository into a specific folder](#Clone a git repository into a specific folder)
 * to [download an archive file and extract it in a specific folder](#Download an archive and extract)
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


## Macros

### Download an archive and extract

If you want to install PyPy into `/opt/pypy`, you can do it like this;

    {% from "basesystem/macros/unpacker.sls" import unpack_remote %}
    {{ unpack_remote('/opt/pypy', 'https://bitbucket.org/pypy/pypy/downloads/pypy-2.5.1-linux.tar.bz2') }}

You can also use pillars.

    # In a pillar
    foobar:
      /opt/pypy:
        href: https://bitbucket.org/pypy/pypy/downloads/pypy-2.5.1-linux.tar.bz2

Then, use in a state:

    {% from "basesystem/macros/unpacker.sls" import unpack_remote_loop %}
    {% set foobar = salt['pillar.get']('foobar') %}
    {{ unpack_remote_loop(foobar)}}


Refer to the comments in [macros/unpacker.sls](./basesystem/macros/unpacker.sls)


### Clone a git repository into a specific folder

If you want to clone into `/srv/webapps/publican/`, called directly;

    {% from "basesystem/macros/git.sls" import git_clone %}
    {{ git_clone('/srv/webapps/publican', 'https://github.com/webspecs/publican.git') }}

You can also use pillars.

Let’s say you are working on a specific branch and you also want an archive to be extracted inside
the git repo.

If the file is downloaded before the `git clone` is made, it would’t work. You have to tell it explicitly.

In pillars, you can do it like this;

    # In a pillar
    foobarbaz:
      git_repos:
        /srv/webapps/publican:
          origin: https://github.com/webplatform/publican.git
          branch: task-based-docker
          before:
            - /srv/webapps/publican/spec-data
          remotes:
            upstream: https://github.com/webspecs/publican.git
      archives:
        /srv/webapps/publican/spec-data:
          href: https://static.webplatform.org/packages/spec-data.tar.bz2
          user: webapps

... we could use both macros together from this pillar like this;

    {% from "basesystem/macros/unpacker.sls" import unpack_remote_loop %}
    {% set archives = salt['pillar.get']('foobarbaz:archives') %}
    {{ unpack_remote_loop(archives)}}

    # Somewhere else
    {% from "basesystem/macros/git.sls" import git_clone_loop %}
    {% set repos = salt['pillar.get']('foobarbaz:git_repos') %}
    {{ git_clone_loop(repos) }}

Refer to the comments in [macros/git.sls](./basesystem/macros/git.sls).


  [wpd]: https://www.webplatform.org/
