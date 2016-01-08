class fastlane {

  package { 'build-essential':
    ensure => 'installed',
  }

  package { 'fastlane':
    ensure => 'latest',
    provider => 'gem',
    install_options => '--verbose',
  }
}
