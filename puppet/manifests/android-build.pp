# Installs android build server and gitlab runner

class { 'gitlab_runner':
    token => hiera('gitlab_runner::token'),
    description => hiera('gitlab_runner::description'),
}

class { 'jdk':

}

include android

class { 'fastlane':

}
