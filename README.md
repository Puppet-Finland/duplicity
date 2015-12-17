# puppet-duplicity

A Puppet module for managing duplicity

# Module usage

* [Class: duplicity](manifests/init.pp)
* [Class: duplicity::s3](manifests/s3.pp)
* [Define: duplicity::backup::s3](manifests/backup/s3.pp)

# Dependencies

See [metadata.json](metadata.json).

# Operating system support

This module has been tested on

* Debian 8

Any *NIX-style operating system should work out of the box or with small
modifications.

For details see [params.pp](manifests/params.pp).
