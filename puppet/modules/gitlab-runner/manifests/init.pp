#
# apt-get install -y gitlab-ci-multi-runner
##
class "gitlab-runner" (
  $url = "https://ci.gitlab.com/",
  $token = "REGISTRATION_TOKEN",
  $description = "Puppet provisioned GitLab CI runner",
  $executor = "shell"
) {

  package { 'curl':
    ensure => 'installed',
  }
  exec { 'add gitlab apt repository':
    command => 'curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | bash',
    path => ["/bin", "/usr/bin", "/usr/sbin"],
    environment => 'os=ubuntu dist=trusty',
  }
  package { 'gitlab-ci-multi-runner':
    ensure => 'installed',
  }

  service { 'gitlab-runner':
    ensure => running,
    enable => true,
    hasrestart => true,
    hasstatus  => true,
  }

  exec { 'register runner':
    command => "gitlab-ci-multi-runner register \
--non-interactive \
--url \"${url}\" \
--registration-token \"${token}\" \
--description \"${description}\" \
--executor \"${executor}\" \
",
    path => ["/bin", "/usr/bin", "/usr/sbin"],
  }
}
