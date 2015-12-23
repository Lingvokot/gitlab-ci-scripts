#!/bin/sh

############################
### Installs puppet,
###   provisions a server
###     with puppet manifes
##############################

# Change working dir to current
cd "$(dirname "$0")"

# One-liner to install puppet
curl -sS  https://raw.githubusercontent.com/hashicorp/puppet-bootstrap/master/ubuntu.sh | sh

# Remove templatedir config option to prevent deprecation warning
sed -e '/templatedir/ s/^#*/#/' -i.back /etc/puppet/puppet.conf

# install gem for hiera secret variables
gem install hiera-eyaml

# Execute our manifest
puppet apply --verbose --debug --hiera_config ./puppet/hiera.yaml --modulepath ./puppet/modules ./puppet/init.pp
