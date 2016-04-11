
class jdk {

  include apt

  package { 'python-software-properties':
    ensure => 'installed',
  }

  apt::ppa { 'ppa:webupd8team/java':
  } ~>
  exec { 'accept Oracle license':
    command => 'echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections',
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  } ~>
  package { 'oracle-java7-installer':
    ensure => 'installed',
  }

}
