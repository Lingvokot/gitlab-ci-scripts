class fastlane {

  package { 'fastlane':
    ensure => 'latest',
    provider => 'gem',
    install_options => '--verbose',
  }

}
