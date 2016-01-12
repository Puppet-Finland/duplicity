# puppet-duplicity

A Puppet module for managing duplicity

# Module usage

It is fairly straightforward to backup things to Amazon Web. First create a new 
GPG keypair, then check its key ID using

    $ gpg --list-keys

Once you know the key ID, export both the public and private parts into an 
ASCII-armored file:

    $ gpg --output <key-id>-public.key --armor --export <key-id>
    $ gpg --output <key-id>-private.key --armor --export-secret-key <key-id>

Copy both keys to the Puppet fileserver's 'files' directory. Then create a 
bucket to AWS and, if necessary, also create an EC2 access key pair.

Finally add your GPG and AWS details into common.yaml or similar:

    classes:
        - duplicity
        - duplicity::s3

    duplicity::gpg_key_id: 'your_gpg_key_id'
    duplicity::s3::gpg_passphrase: 'your_gpg_passphrase'
    duplicity::s3::aws_access_key_id: 'your_aws_access_key_id'
    duplicity::s3::aws_secret_access_key: 'your_aws_secret_access_key'
    duplicity::s3::bucket: 'your_bucket_name'
    duplicity::s3::full_interval: '1W'
    duplicity::s3::hour: '14'
    duplicity::s3::minute: '38'

Then add backup definitions as necessary:

    duplicity::s3::backups:
        local:
            source: '/var/backups/local'
        etc:
            source: '/etc'

With the above backup definitions two backups would be generated for 
server.domain.com:

* server.domain.com-local
* server.domain.com-etc

Prepending the backup title with $::fqdn helps prevent backup directory clashes.

Full and incremental backup intervals can also be defined manually. One can also 
flip a switch to only take (full) backups every other week:

    duplicity::s3::backups:
        local-full:
            type: 'full'
            source: '/var/backups/local'
            basename: 'local'
            # Full backup every other Saturday
            weekday: '6'
            hour: '2'
            on_even_weeks_only: true
        local-incremental:
            type: 'incremental'
            source: '/var/backups/local'
            basename: 'local'
            # Incremental every Mon-Sat
            weekday: '1-6'
            hour: '0'
            minute: '30'

The $basename parameter is used to ensure the that full and incremental backups
go into the same directory.

For more details refer to the class documentation:

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
