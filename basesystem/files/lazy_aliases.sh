# Managed by Salt Stack
# {{ source }}

alias webapps='sudo -i su webapps'
alias besu='sudo -HE bash -l'
alias scr='screen -dd -R'

alias lazy_netstat='netstat -tulpn'
alias lazy_gentoken='openssl rand -base64 32'
alias lazy_git_shortlog='git shortlog -sn'

lazy_mem () {
  ps -ylC "$@" --sort:rss | awk '!/RSS/ { s+=$8 } END { printf "%s\n", "Total memory used:"; printf "%dM\n", s/1024 }'
}

# ref: http://www.commandlinefu.com/commands/view/3543/show-apps-that-use-internet-connection-at-the-moment.
lazy_lsof_network_services() {
  lsof -P -i -n | cut -f 1 -d " "| uniq | tail -n +2
}

lazy_openssl_read() {
  openssl x509 -text -in $1 | more
}

lazy_lsof_socks(){
  lsof -P -i -n | less
}

lazy_lsof() {
  /usr/bin/lsof -w -l | less
}

lazy_util_trailing_whitespace() {
  if [ -f "$1" ]; then
    sed -i 's/[ \t]*$//' "$1"
  fi
}

# ref: http://stackoverflow.com/questions/26370185/how-do-criss-cross-merges-arise-in-git
lazy_git_log() {
  git log --graph --oneline --decorate --all
}

lazy_git_search_file() {
  git log --all --name-only --pretty=format: | sort -u | grep "$1"
}

lazy_git_phplint_changed() {
  git status -s | grep 'php$' | awk '{print $2}' | xargs -n1 php -l
}

lazy_git_phplint() {
  if [[ $1 ]]; then
    against="${1}"
  else
    against="HEAD"
  fi
  git diff-tree --no-commit-id --name-only --ignore-space-at-eol --pretty=oneline --abbrev-commit -r ${against} | grep 'php$' | xargs -n1 php -l
}


# ref: http://hardenubuntu.com/disable-services
lazy_procs() {
  initctl list | grep running
}

lazy_net_connections() {
  netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
}

lazy_util_webserver () {
  python -m SimpleHTTPServer 8080
}

lazy_util_conv_yml_json () {
  if [ -f "$1" ]; then
    python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=2)' < $1 > $1.new.json
  fi
}

lazy_util_conv_json_yml () {
  if [ -f "$1" ]; then
    python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin),sys.stdout,allow_unicode=True,default_flow_style=False)' < $1 > $1.new.yml
  fi
}


lazy_html_minify () {
  if [ -f "$1" ]; then
    cat $1 | tr '\t' ' ' | tr '\n' ' ' | sed 's/  //g' | sed 's/> </></g' > $1
  fi
}
