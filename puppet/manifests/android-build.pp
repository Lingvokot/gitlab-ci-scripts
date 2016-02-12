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

file { '/etc/profile.d/android.sh':
  ensure => 'file',
  content => '
export ANDROID_HOME=/usr/local/android/android-sdk-linux
export ANDROID_TOOLS_PATH=$ANDROID_HOME/tools
export ANDROID_PLATFORM_TOOLS=$ANDROID_HOME/platform-tools

export PATH="$ANDROID_TOOLS_PATH:$ANDROID_PLATFORM_TOOLS:$PATH"
  ',
}
