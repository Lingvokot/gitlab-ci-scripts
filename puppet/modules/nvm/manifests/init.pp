package { 'git':
  ensure => 'installed',
}
package { 'build-essential':
  ensure => installed,
}
package { 'openssl':
  ensure => installed,
}
package { 'libssl-dev':
  ensure => installed,
}
package { 'curl':
  ensure => installed,
}

exec { 'clone nvm repo':
  command => 'git clone git@github.com:creationix/nvm.git /opt/nvm',
  path => ["/bin", "/usr/bin", "/usr/sbin"],
}
file { ['/usr/local/nvm', ['/usr/local/node']]:
  ensure => 'directory',
  mode => '755',
}

file { '/etc/profile.d/nvm.sh':
  ensure => 'file',
  content => '
export NVM_DIR=/usr/local/nvm
source /opt/nvm/nvm.sh

export NPM_CONFIG_PREFIX=/usr/local/node
export PATH="/usr/local/node/bin:$PATH"
  ',
}
