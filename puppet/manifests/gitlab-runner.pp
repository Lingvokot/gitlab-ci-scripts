### Gitlab runner manifest
# Simple installs Gitlab CI Runner and nothing else

class { 'gitlab_runner':
    token => hiera('gitlab_runner::token'),
    description => hiera('gitlab_runner::description'),
}

# Place build-export.sh script
file { '/opt/build-export.sh':
  ensure => file,
  mode => 'ug+x',
  source => 'puppet:///modules/scripts/build-export.sh',
}
