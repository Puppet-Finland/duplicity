#
# == Define: duplicity::backup::s3
#
# Backup things to Amazon S3
#
# == Parameters
#
# [*ensure*]
#   The state of the resource. Valid values are 'present' and 'absent'.
# [*source*]
#   The source path to backup.
# [*type*]
#   The type of backup. Valid values are 'full' and 'incremental'. If this 
#   parameter is not given, the backup type is determined by the age of previous 
#   full backup. See the $full_interval parameter for details.
# [*basename*]
#   This is used as part of the remote path. It is prepended with $::fqdn to 
#   produce the full path at S3. For example, if $::fqdn is "server.domain.com" 
#   and $basename is "local", then the files will be copied to 
#   "server.domain.com-local". The default value is taken from the resource 
#   $title, but if you're managing full/incremental backups yourself using the 
#   $type parameter, then you need to use a matching $basename for both backup 
#   types.
# [*bucket*]
#   The name of the S3 bucket. Defaults to $::duplicity::s3::bucket.
# [*full_interval*]
#   The interval between taking full backups. See duplicity man-page for the 
#   format. Defaults to $::duplicity::s3::full_interval. This parameter has no 
#   effect if the $type parameter is used.
# [*hour*]
#   The hour when the cronjob runs. Defaults to $::duplicity::s3::hour.
# [*minute*]
#   The minute when the cronjob runs. Defaults to $::duplicity::s3::minute.
# [*weekday*]
#   The weekday when the cronjob runs. Defaults to $::duplicity::s3::weekday.
# [*monthday*]
#   The day of the month the cronjob runs. Defaults to 
#   $::duplicity::s3::monthday.
#
define duplicity::backup::s3
(
    $source,
    $type = undef,
    $bucket = undef,
    $basename = $title,
    $ensure = 'present',
    $full_interval = undef,
    $hour = undef,
    $minute = undef,
    $weekday = undef,
    $monthday = undef,
    $volsize = undef,
)
{
    # Validate the backup type, if given
    if $type { validate_re("${type}", '^(full|incremental)$') }

    # Ensure that we have everything we need for this define to work
    include ::duplicity::s3

    # Generate a unique remote path
    $full_remote_path = "${::fqdn}-${basename}"

    # Allow overriding the defaults in ::duplicity::s3
    if $full_interval == undef { $l_full_interval = $::duplicity::s3::full_interval } else { $l_full_interval = $full_interval }
    if $bucket == undef        { $l_bucket        = $::duplicity::s3::bucket        } else { $l_bucket        = $bucket        }
    if $hour == undef          { $l_hour          = $::duplicity::s3::hour          } else { $l_hour          = $hour          }
    if $minute == undef        { $l_minute        = $::duplicity::s3::minute        } else { $l_minute        = $minute        }
    if $weekday == undef       { $l_weekday       = $::duplicity::s3::weekday       } else { $l_weekday       = $weekday       }
    if $monthday == undef      { $l_monthday      = $::duplicity::s3::monthday      } else { $l_monthday      = $monthday      }
    if $volsize == undef       { $l_volsize       = $::duplicity::s3::volsize       } else { $l_volsize       = $volsize       }

    # Get the rest of the values from ::duplicity::s3
    $l_gpg_passphrase = $::duplicity::s3::gpg_passphrase
    $l_aws_access_key_id = $::duplicity::s3::aws_access_key_id
    $l_aws_secret_access_key = $::duplicity::s3::aws_secret_access_key
    $l_encrypt_secret_keyring = $::duplicity::s3::encrypt_secret_keyring
    $l_s3_endpoint = $::duplicity::s3::s3_endpoint
    $l_gpg_key_id = $::duplicity::config::gnupg::gpg_key_id

    # Determine backup type (full, incremental, detect automatically)
    if $type {
        $type_params = $type
    } else {
        $type_params = "--full-if-older-than ${l_full_interval}"
    }

    # Add a cronjob. Note that "--always-trust" GPG option is needed, or GPG may 
    # refuse to encrypt because it can't determine if the key belongs to the 
    # user running the GPG command. We also need to pipe stdout into /dev/null, as
    # "--verbosity error" still produces output on every run. Fortunately duplicity
    # outputs errors into stdout.
    #
    cron { "duplicity-backup-s3-${title}":
        ensure      => $ensure,
        user        => root,
        command     => "duplicity ${type_params} --gpg-options \"--always-trust\" --volsize ${l_volsize} --encrypt-key ${l_gpg_key_id} --sign-key ${l_gpg_key_id} --verbosity error ${source} s3://${l_s3_endpoint}/${l_bucket}/${full_remote_path} > /dev/null",
        environment => [ 'PATH=/bin:/usr/bin',
                        "PASSPHRASE=${l_gpg_passphrase}",
                        "SIGN_PASSPHRASE=${l_gpg_passphrase}",
                        "AWS_ACCESS_KEY_ID=${l_aws_access_key_id}",
                        "AWS_SECRET_ACCESS_KEY=${l_aws_secret_access_key}"
                      ],
        hour        => $l_hour,
        minute      => $l_minute,
        weekday     => $l_weekday,
        monthday    => $l_monthday,
    }
}
