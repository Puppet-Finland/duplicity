# puppet-duplicity

A Puppet module for managing duplicity and backing up things to Amazon S3.

# Module usage

It is fairly straightforward to backup things to Amazon S3. First create a new GPG keypair:

    $ gpg2 --gen-key

then check its key ID using

    $ gpg2 --list-keys

Once you know the key ID, export both the public and private parts into an 
ASCII-armored file:

    $ gpg2 --output <key-id>-public.key --armor --export <key-id>
    $ gpg2 --output <key-id>-private.key --armor --export-secret-key <key-id>

For deploying the public and private key you have two options:

 * Define $gpg_private_key_source and $gpg_public_key_source parameters manually
 * Place the keys to puppet:///files/${gpg_key_id}-private.key" and puppet:///files/${gpg_key_id}-public.key", respectively

Then create a bucket to AWS S3 and, if necessary, create an EC2 access key pair.

The add basic settings to a Puppet manifest (e.g. a profile):

    class { '::duplicity':
        gpg_key_id             => '1D2E50743866CF58739229E376B594D9C5C948A6',
        gpg_private_key_source => 'puppet:///profile/files//1D2E50743866CF58739229E376B594D9C5C948A6-private.key',
        gpg_public_key_source  => 'puppet:///profile/files/1D2E50743866CF58739229E376B594D9C5C948A6-public.key',
    }
    
    class { '::duplicity::s3':
      gpg_passphrase        => 'my-gpg-passphrase',
      s3_endpoint           => 's3.amazonaws.com',
      aws_access_key_id     => 'access-key-id',
      aws_secret_access_key => 'secret-access-key',
      bucket                => 'myorganization-duplicity-backups',
      full_interval         => '1W',
      hour                  => 15,
      minute                => 0,
    }

If you want to get GPG keys from Hiera use the $gpg_public_key_content and $gpg_private_key_content parameters.

Then add backup definitions as necessary:

    ::duplicity::backup::s3 { 'etc':
      source => '/etc',
    }
    
    ::duplicity::backup::s3 { 'local':
      source => '/var/backups/local',
    }

With the above backup definitions two backups would be generated for 
server.domain.com:

* server.domain.com-local
* server.domain.com-etc

Prepending the backup title with $::fqdn helps prevent backup directory clashes.

Full and incremental backup intervals can also be defined manually. One can
also flip a switch to only take (full) backups every other week:

    ::duplicity::backup::s3 { 'local-full':
      type               => 'full',
      source             => '/var/backups/local',
      basename           => 'local',
      # Full backup every other Saturday
      weekday            => 6,
      hour               => 2,
      on_even_weeks_only => true
    
    ::duplicity::backup::s3 { 'local-incremental':
      type     => 'incremental',
      source   => '/var/backups/local',
      basename => 'local',
      # Incremental every Mon-Sat
      weekday  => '1-6',
      hour     => 0,
      minute   => 30,
    }

The $basename parameter is used to ensure the that full and incremental
backups go into the same directory on S3.

# Note on European S3 buckets

Creating S3 buckets in European datacenters is somewhat harder than using the
default (us-east-1) region. With some datacenters you may run into various API
issues, but at least the eu-west-1 datacenter seems to work:

    class { '::duplicity::s3':
      gpg_passphrase        => 'my-gpg-passphrase',
      s3_endpoint           => 's3.eu-west-1.amazonaws.com',
      european_buckets      => true,
      aws_access_key_id     => 'access-key-id',
      aws_secret_access_key => 'secret-access-key',
      bucket                => 'myorganization-duplicity-backups-ireland',
      full_interval         => '1W',
      hour                  => 15,
      minute                => 0,
    }

For more details refer to the class documentation:

* [Class: duplicity](manifests/init.pp)
* [Class: duplicity::s3](manifests/s3.pp)
* [Define: duplicity::backup::s3](manifests/backup/s3.pp)

# Dependencies

See [metadata.json](metadata.json).

# Operating system support

This module has been tested on CentOS 7. And older version of the module was
tested on Debian 8. Any *NIX-style operating system should work out of the
box or with small modifications.
