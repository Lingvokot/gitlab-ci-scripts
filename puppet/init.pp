# TODO: nginx user or group
# TODO restrict access to builds dir

# Create public nginx dir
exec { 'mkdir -p /opt/gitlab-ci-builds/builds/':
  path => ["/bin", "/usr/bin", "/usr/sbin"],
  unless => 'ls /opt/gitlab-ci-builds/builds',
} ~>
file { '/opt/gitlab-ci-builds/builds/':
  ensure => directory,
  mode => 'ug=w,ug=r,a=x',
  owner => root,
  group => root,
  recurse => true,
}

# Place build-export.sh script
file { '/opt/build-export.sh':
  ensure => file,
  mode => 'ug+x',
  source => 'puppet:///modules/scripts/build-export.sh',
}

# Install and configure nginx
class {'nginx':
  nginx_login => hiera('nginx::nginx_login'),
  nginx_password => hiera('nginx::nginx_password'),
}

# Add cron job to remove old dirs
cron { 'clean old builds':
  command => 'find /opt/gitlab-ci-builds/builds -type d -mtime +7 -maxdepth 1 -exec rm -r {} \;',
  monthday => 1,
}
