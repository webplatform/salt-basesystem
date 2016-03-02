Setup Ruby on Rails dependencies:
  cmd.run:
    - unless: test -f /etc/apt/sources.list.d/brightbox-ruby-ng-experimental-trusty.list
    - name: |
        add-apt-repository -y ppa:brightbox/ruby-ng-experimental && \
        apt-get update && \
        apt-get remove --purge -yqq ruby1.9.1
  # You might notice that I'm putting apt-get up here ^ and not
  # a pkg.purged call like I do below with pkg.installed.
  #
  # That's because a state block can only contain one state
  # class (e.g. pkg, cmd) function call (e.g. pkg.installed) per state block.
  #
  # Also, this state block will run **only** if it doesn't find the file
  # /etc/apt/sources.list.d/brightbox-ruby-ng-experimental-trusty.list,
  # which is most likely to happen at first install time.
  pkg.installed:
    - pkgs:
      - ruby2.2
      - libruby2.2
      - ruby2.2-dev
      - ruby2.2-tcltk
      - ruby2.2-doc
      - build-essential
    - require:
      - cmd: Setup Ruby on Rails dependencies
  gem.installed:
    - names:
      - bundler
    - require:
      - cmd: Setup Ruby on Rails dependencies
