# Base system salt state

[WebPlatform][wpd] infrastructure servers runs on the same GNU/Linux distribution; *Ubuntu Linux 14.04 LTS*.
This *salt state* formula is meant to be applied to **every** server and containers we run.

Idea is to have a workspace that’s as close as possible to what every server/container we’re running.



## Features

* system user "**webapps**" who can be used as owner for running processes
* [Macros](#macros):
 * to [clone a git repository into a specific folder](#clone-a-git-repository-into-a-specific-folder)
 * to [download an archive file and extract it in a specific folder](#download-an-archive-and-extract)
 * to [Make a dated archive of a git repository](#make-a-dated-archive-of-a-git-repository)
 * to [Create a mirror of a git repository](#create-a-mirror-of-a-git-repository)
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

If you want to install PyPy archive into `/opt/pypy`, you can do it like this;

**Use directly in a state:**

    {% from "basesystem/macros/unpacker.sls" import unpack_remote %}
    {{ unpack_remote('https://static.webplatform.org/wpd/packages/python/pypy-2.5.1-linux64.tar.bz2', '/opt/pypy') }}

**Use directly in states, but the extracted files would be owned by a particular user:**

    {% from "basesystem/macros/unpacker.sls" import unpack_remote %}
    {{ unpack_remote('https://static.webplatform.org/wpd/packages/python/pypy-2.5.1-linux64.tar.bz2', '/opt/pypy', {'user':'ubuntu'}) }}

**Use in states, with pillar:**

- Each pillar key (e.g. `/opt/pypy`) MUST be an absolute path
- The `href` key is the only required attribute. Others are optional.
- Supported keys:
  - user: the local user who will be running the state and be set as owner

    ```yaml
    foobar:
      /opt/pypy:
        href: https://static.webplatform.org/wpd/packages/python/pypy-2.5.1-linux64.tar.bz2
      /srv/webapps/publican/spec-data:
        href: https://static.webplatform.org/wpd/packages/bikeshed/spec-data.bar.bz2
        user: webapps
    ```

Then, in a state file;

    {% from "basesystem/macros/unpacker.sls" import unpack_remote_loop %}
    {% set foobar = salt['pillar.get']('foobar') %}
    {{ unpack_remote_loop(foobar)}}



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


### Make a dated archive of a git repository

Imagine you want to make a dated snapshot of a git repo at `/srv/salt` and store it to `/mnt/backup/gitarchives/`;

In a state file or a reactor you can do;

    {% from "basesystem/macros/git.sls" import git_archive %}
    {{ git_archive('/srv/salt', '/mnt/backup/gitarchives') }}


### Create a mirror of a git repository

If you want to have a local mirror of a private repository, you could do it like this;

In a state file or a reactor you can do;

    {% from "basesystem/macros/git.sls" import git_mirror %}
    {% set mirror_args = {'auth_key': '/home/foo/.ssh/passwordless'} %}
    {{ git_mirror('git@github.com:webplatform/salt-basesystem.git', '/mnt/gitmirrors/basesystem', mirror_args) }}

Beware though. If your private key is passphrase protected, you would need to enter it everytime you execute it.

  [wpd]: https://www.webplatform.org/
