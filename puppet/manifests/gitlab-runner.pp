### Gitlab runner manifest
# Simple installs Gitlab CI Runner and nothing else

class { 'gitlab_runner':
    token => hiera('gitlab_runner::token'),
    description => hiera('gitlab_runner::description'),
}
