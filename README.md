# Gitlab CI assets dir

Contains our assets dir for Gitlab CI

Manifests get installed with `install.sh` script.

Example:
```
install.sh android-build
```

## Pre-install steps and additional info

We use *Ubuntu Server 14.04 LTS* distro for the server.
You may need your pem keys (`private_key.pkcs7.pem`, `public_key.pkcs7.pem`) to get secure variables.

Steps to setup:
* Place your keys for hiera-eyaml in paths:
  * `pkcs7_private_key`: `/etc/puppet/keys/eyaml/private_key.pkcs7.pem`
  * `pkcs7_public_key`: `/etc/puppet/keys/eyaml/public_key.pkcs7.pem`
* Run `install.sh` script. It should automatically install their dependencies.

### Remote upload

It's possible to upload files remotely. Define this environment variables:
* `BUILD_EXPORT_REMOTE_HOST` - remote host to copy directory to
* `BUILD_EXPORT_REMOTE_USER` - host user to copy remote dir

> Paths stay the same for remote upload like for local upload

## Installation

> It's possible to enable stdout of child commands with DEBUG env var: `DEBUG=y install.sh manifest`

### Runner provision

Included in the `gitlab-runner` manifest:
```
install.sh gitlab-runner
```

#### Android build server

Combined with Gitlab CI Runner setup.

Installation is done via `android-build` manifest:
```
install.sh android-build
```

### Static server

We use it as "Gitlab CI extension" for our *JavaScript* projects (*React Native*).

With help of `build-export.sh`, it's possible to:
  * generate custom badges via web service http://shields.io
  * always have link on latest build for *master* branch
  * copy your build artifacts to directory exposed into WEB by nginx!

We use HTTP basic auth for access control. But badges are public-visible by default.

Old builds get removed from builds dir by cron after they stay __7 days__.
See main manifest (`static-server`) for more info.

Installation is done via `static-server` manifest:
```
install.sh static-server
```

#### Unrelated notes on Gitlab CI setup

Get coverage info display in Gitlab CI build log using *istanbul* as coverage tool:
1. Goto Project settings
2. Find *Continuous Integration* section.
3. Enter this REGexp to *Test coverage parsing* entry: `Lines\s*:\s*(\d*\.?\d+)%`
Now Gitlab CI will display covered lines percent:

![Istanbul coverage gitlab](assets/istanbul-coverage.png)

> Also, for istanbul, this line may be helpful: `All files(?:\s*\|\s*\d*\.?\d+\s*){3}\|\s*((\d*\.?\d+))\s*\|`

To enforce coverage percent, consult your coverage program.
We use *istanbul* (and *isparta*), so we can check coverage with command `istanbul check`

An example for 90% lines covered:
```
istanbul check --lines 90
```

To enforce code style on your build server, use linter.
We use `1` option for some rules in our *.eslintrc*.

# Create Merge Request on Gitlab in command line

I've created this small script, and it *actually* works.
You need Ruby and Bash to use it.
It's on Gist: https://gist.github.com/ColCh/35c495786e25e33976706016eed7f200
