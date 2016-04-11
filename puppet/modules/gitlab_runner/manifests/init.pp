#
# apt-get install -y gitlab-ci-multi-runner
##
class gitlab_runner (
  $url = "https://ci.gitlab.com/",
  $token = "REGISTRATION_TOKEN",
  $description = "Puppet provisioned GitLab CI runner",
  $executor = "shell"
) {

  package { 'curl':
    ensure => 'installed',
  }

  exec { 'add gitlab apt repository':
    creates => '/etc/apt/sources.list.d/runner_gitlab-ci-multi-runner.list',
    command => 'curl -L -sS https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | os=ubuntu dist=trusty bash',
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  } ~>
  package { 'gitlab-ci-multi-runner':
    ensure => 'installed',
  }

  service { 'gitlab-runner':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus  => true,
  }

  file { '/etc/profile.d/build_export.sh':
    ensure => 'file',
    content => '
# Correct this as you wish
#export BUILD_EXPORT_SCRIPT="/home/gitlab-runner/build-export.sh"
#export BUILD_EXPORT_REMOTE_HOST="127.0.0.1"
#export BUILD_EXPORT_REMOTE_USER="build-export-user-here"
    ',
  }

#   exec { 'register runner':
#     command => "gitlab-ci-multi-runner register \
# --non-interactive \
# --url \"${url}\" \
# --registration-token \"${token}\" \
# --description \"${description}\" \
# --executor \"${executor}\" \
# ",
#     path => ["/bin", "/usr/bin", "/usr/sbin"],
#   }
}
