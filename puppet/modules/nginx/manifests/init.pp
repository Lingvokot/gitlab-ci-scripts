class nginx (
  $basic_auth_hint = 'Auth Lingvokot',
  $nginx_password_file_path = '/etc/nginx/nginx-passwords',
  $nginx_login = 'user',
  $nginx_password = 'user'
) {
  package { 'nginx': ensure => installed }

  service { 'nginxd':
    name => 'nginx',
    ensure => running,
    enable => true,
    hasrestart => true,
  }

  exec { 'nginx-password':
    creates => $nginx_password_file_path,
    command => "echo \"${nginx_login}:$(openssl passwd \"${nginx_password}\")\" > ${$nginx_password_file_path}",
    logoutput => false,
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }

  file { '/etc/nginx/sites-available/nginx-config':
    ensure => file,
    content => template('nginx/nginx-config.erb'),
  } ~>
  file { '/etc/nginx/sites-enabled/default':
    ensure => link,
    target => '/etc/nginx/sites-available/nginx-config',
    notify => Service['nginxd'],
  }



}
