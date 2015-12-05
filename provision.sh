#!/bin/sh

# Docker?
# curl -sSL https://get.docker.com/ | sh

# Nodejs
curl -sL https://deb.nodesource.com/setup_4.x | bash
apt-get install -y nodejs

# For native node modules
apt-get install -y build-essential

# Gitlab CI multi runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | bash
apt-get install -y gitlab-ci-multi-runner

echo 'run "gitlab-ci-multi-runner register"'
