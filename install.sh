#!/bin/sh

############################
### Installs puppet,
###   provisions a server
###     with puppet manifes
##############################

# Change working dir to current
cd "$(dirname "$0")"

# Installs puppet
function prepare-puppet {
  # One-liner to install puppet
  curl -sS  https://raw.githubusercontent.com/hashicorp/puppet-bootstrap/master/ubuntu.sh | sh

  # Remove templatedir config option to prevent deprecation warning
  sed -e '/templatedir/ s/^#*/#/' -i.back /etc/puppet/puppet.conf
}

# Check for provision dependencies
function check_deps {

  if ! type "puppet" > /dev/null; then
    prepare-puppet
  fi

  if ! type "eyaml" > /dev/null; then
    # install gem for hiera secret variables
    gem install hiera-eyaml
  fi

}

function apply-manifest {
  # Execute our manifest
  puppet apply --verbose --debug --hiera_config ./puppet/hiera.yaml --modulepath ./puppet/modules ./puppet/$1.pp
}

# Entry point
function main {
  check_deps
  apply-manifest $1
}

# Let it go
if [ -n "$1" ]; then
  main $1
else
  echo "Usage: install.sh init"
fi
