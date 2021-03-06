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
  command => 'git clone https://github.com/creationix/nvm.git /opt/nvm',
  path => ["/bin", "/usr/bin", "/usr/sbin"],
  creates => '/opt/nvm',
}
file { ['/usr/local/nvm', ['/usr/local/node']]:
  ensure => 'directory',
  mode => '755',
  owner => 'gitlab-runner',
  group => 'gitlab-runner',
}

file { '/etc/profile.d/nvm.sh':
  ensure => 'file',
  content => '
export NVM_DIR=/usr/local/nvm
source /opt/nvm/nvm.sh

export PATH="/usr/local/node/bin:$PATH"
  ',
}
