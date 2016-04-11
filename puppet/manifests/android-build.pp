# Installs android build server and gitlab runner

class { 'gitlab_runner':
    token => hiera('gitlab_runner::token'),
    description => hiera('gitlab_runner::description'),
}

class { 'jdk':

}

include android

exec { 'update android':
  command => 'echo yes | android update sdk --all --filter tools --no-ui --force > /dev/null',
  path => ["/bin", "/usr/bin", "/usr/sbin", "/usr/local/android/android-sdk-linux/tools/"],
}

exec { 'install android build tools':
  command => 'echo yes | android update sdk -u -a -t 2,5,33,105,136,137 --no-ui --force > /dev/null',
  path => ["/bin", "/usr/bin", "/usr/sbin", "/usr/local/android/android-sdk-linux/tools/"],
}

class { 'fastlane':

}

file { '/etc/profile.d/android.sh':
  ensure => 'file',
  content => '
export ANDROID_HOME=/usr/local/android/android-sdk-linux
export ANDROID_TOOLS_PATH=$ANDROID_HOME/tools
export ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools

export PATH="$ANDROID_TOOLS_PATH:$ANDROID_PLATFORM_TOOLS:$PATH"
  ',
}

file { '/etc/profile.d/android_secrets.sh':
  ensure => 'file',
  content => '
# Correct this as you wish
#export SUPPLY_KEY="/path/to/file.p12"
#export ANDROID_KEYSTORE="/path/to/keystore.jks"
#export ANDROID_KEYSTORE_PASSWORD="keystore password"
  ',
}
