### Gitlab runner manifest
# Simple installs Gitlab CI Runner and nothing else

class { 'gitlab-runner':
    token => hiera('gitlab-runner::token'),
    description => hiera('gitlab-runner::description'),
}
