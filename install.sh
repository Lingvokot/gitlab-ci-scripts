#!/bin/bash

###################################
### Installs puppet,
###   checks for eyaml installation
###     executes puppet manifest
###################################

# Change working dir to puppet dir
cd "$(dirname "$0")/puppet"

# Installs puppet
prepare_puppet () {
  # this function is from:
  # https://raw.githubusercontent.com/hashicorp/puppet-bootstrap/master/ubuntu.sh
  echo "Configuring PuppetLabs repo..."
  wget -q http://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb >/dev/null
  dpkg -i puppetlabs-release-pc1-trusty.deb >/dev/null
  apt-get update >/dev/null

  echo "Installing Puppet..."
  DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet-agent >/dev/null

  echo "Puppet installed!"

  # Install RubyGems for the provider
  echo "Installing RubyGems..."
  gem install --no-ri --no-rdoc rubygems-update
  update_rubygems >/dev/null
}

# Check for provision dependencies
check_deps () {

  # Ruby 2.2dev needed by fastlane
  if ! which ruby > /dev/null 2>&1 || [[ ! "$(ruby -v)" == *"ruby 2.2"* ]]; then
    echo "Installing ruby version 2.2 ..."
    apt-get install -y software-properties-common >/dev/null
    apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
    apt-get update  >/dev/null
    apt-get install -qq -y ruby2.2 ruby2.2-dev ruby-switch >/dev/null
    echo "Switch system ruby version to 2.2"
    ruby-switch --set ruby2.2 >/dev/null
  fi

  if [ ! -f "/opt/puppetlabs/bin/puppet" ] ; then
    echo "Puppet 4 is not found at /opt/puppetlabs/bin/puppet. Installing puppet..."
    prepare_puppet
  fi

  if ! which librarian-puppet > /dev/null 2>&1; then
    echo "Librarian-puppet command is not found. Installing librarian-puppet gem..."
    # install gem for puppet modules
    gem install librarian-puppet >/dev/null
  fi

  if ! which eyaml > /dev/null 2>&1; then
    # install gem for hiera secret variables
    echo "Eyaml command is not found. Installing hiera-eyaml gem..."
    # for puppet
    /opt/puppetlabs/puppet/bin/gem install hiera-eyaml >/dev/null
    ln -s /opt/puppetlabs/puppet/bin/eyaml /opt/puppetlabs/bin/eyaml
    # system-wide
    gem install hiera-eyaml >/dev/null
  fi

}

apply_manifest () {
  # Execute our manifest
  echo "executing manifest $1 ..."
  /opt/puppetlabs/bin/puppet apply --verbose --debug --hiera_config ./hiera.yaml --modulepath ./librarian-modules:./modules ./manifests/$1.pp
}

# Entry point
main () {
  check_deps
  PATH="/opt/puppetlabs/bin/:$PATH" librarian-puppet install --path=librarian-modules
  apply_manifest $1
}

# Let it go
if [ -n "$1" ]; then
  main $1
else
  echo -n "Manifest install script\nUsage: install.sh manifest\nSee manifests dir to find available manifests\n"
fi
