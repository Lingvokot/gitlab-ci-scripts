## android-build manifest
# install gitlab-runner
#         fastlane
#         java (jdk)
#         android-sdk

class { 'gitlab-runner':
    token => hiera('gitlab-runner::token'),
    description => hiera('gitlab-runner::description'),
}

class { 'java': }

class { 'android': }

class { 'fastlane': }
