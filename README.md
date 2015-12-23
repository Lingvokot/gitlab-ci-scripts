# Gitlab CI assets dir

Contains our assets dir for Gitlab CI

## Runner provision

TODO. For now, it's in the `provision.sh` script

## Static server

We use it as "Gitlab CI extension" for our *JavaScript* projects (*React Native*).

With help of `build-export.sh`, it's possible to:
  * generate custom badges via web service http://shields.io
  * always have link on latest build
  * copy your build artifacts to directory exposed into WEB by nginx!

We use HTTP basic auth for access control. But badges are public-visible by default.

Old builds get removed from builds dir by cron after they stay __7 days__.
See main manifest `init.pp` for more info.

### Install

We use *Ubuntu Server 14.04 LTS* distro for the server.
You may need your pem keys (`private_key.pkcs7.pem`, `public_key.pkcs7.pem`) to get secure variables.

Steps to setup:
* Place your keys for hiera-eyaml in paths:
  * `pkcs7_private_key`: `/etc/puppet/keys/eyaml/private_key.pkcs7.pem`
  * `pkcs7_public_key`: `/etc/puppet/keys/eyaml/public_key.pkcs7.pem`
* Run `install.sh` script. It should automatically install their dependencies.

### Unrelated notes on Gitlab CI setup

Get coverage info display in Gitlab CI build log using *istanbul* as coverage tool:
1. Goto Project settings
2. Find *Continuous Integration* section.
3. Enter this REGexp to *Test coverage parsing* entry: `Lines\s*:\s*(\d*\.?\d+)%`
Now Gitlab CI will display covered lines percent:
[IMAGE HERE]


To enforce coverage percent, consult your coverage program.
We use *istanbul* (and *isparta*), so we can check coverage with command `istanbul check`

An example for 90% lines covered:
```
istanbul check --lines 90
```

To enforce code style on your build server, use linter.
We use `1` option for some rules in our *.eslintrc*.
