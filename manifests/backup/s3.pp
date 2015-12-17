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
# [*title*]
#   The resource title is used as part of the remote path. It is prepended with 
#   $::fqdn to produce the full path at S3. For example, if the $::fqdn is 
#   "server.domain.com" and the $title is "local", then the files will be copied 
#   to "server.domain.com-local".
# [*bucket*]
#   The name of the S3 bucket. Defaults to $::duplicity::s3::bucket.
# [*full_interval*]
#   The interval between taking full backups. See duplicity man-page for the 
#   format. Defaults to $::duplicity::s3::full_interval.
# [*hour*]
#   The hour when the cronjob runs. Defaults to $::duplicity::s3::hour.
# [*minute*]
#   The minute when the cronjob runs. Defaults to $::duplicity::s3::minute.
# [*weekday*]
#   The minute when the cronjob runs. Defaults to $::duplicity::s3::weekday.
#
define duplicity::backup::s3
(
    $source,
    $bucket = undef,
    $ensure = 'present',
    $full_interval = undef,
    $hour = undef,
    $minute = undef,
    $weekday = undef
)
{
    # Ensure that we have everything we need for this define to work
    include ::duplicity::s3

    # Generate a unique remote path
    $full_remote_path = "${::fqdn}-${title}"

    # Allow overriding the defaults in ::duplicity::s3
    unless $full_interval { $l_full_interval = $::duplicity::s3::full_interval } else { $l_full_interval = $full_interval }
    unless $bucket        { $l_bucket        = $::duplicity::s3::bucket        } else { $l_bucket        = $bucket        }
    unless $hour          { $l_hour          = $::duplicity::s3::hour          } else { $l_hour          = $hour          }
    unless $minute        { $l_minute        = $::duplicity::s3::minute        } else { $l_minute        = $minute        }
    unless $weekday       { $l_weekday       = $::duplicity::s3::weekday       } else { $l_weekday       = $weekday       }

    # Get the rest of the values from ::duplicity::s3
    $l_gpg_passphrase = $::duplicity::s3::gpg_passphrase
    $l_aws_access_key_id = $::duplicity::s3::aws_access_key_id
    $l_aws_secret_access_key = $::duplicity::s3::aws_secret_access_key
    $l_encrypt_secret_keyring = $::duplicity::s3::encrypt_secret_keyring
    $l_s3_endpoint = $::duplicity::s3::s3_endpoint
    $l_gpg_key_id = $::duplicity::config::gnupg::gpg_key_id

    # Add a cronjob. Note that "--always-trust" GPG option is needed, or GPG may 
    # refuse to encrypt because it can't determine if the key belongs to the 
    # user running the GPG command. We also need to pipe stdout into /dev/null, as
    # "--verbosity error" still produces output on every run. Fortunately duplicity
    # outputs errors into stdout.
    #
    cron { "duplicity-backup-s3-${title}":
        ensure      => $ensure,
        user        => root,
        command     => "duplicity --gpg-options \"--always-trust\" --full-if-older-than ${l_full_interval} --encrypt-key ${l_gpg_key_id} --sign-key ${l_gpg_key_id} --verbosity error ${source} s3://${l_s3_endpoint}/${l_bucket}/${full_remote_path} > /dev/null",
        environment => [ 'PATH=/bin:/usr/bin',
                        "PASSPHRASE=${l_gpg_passphrase}",
                        "SIGN_PASSPHRASE=${l_gpg_passphrase}",
                        "AWS_ACCESS_KEY_ID=${l_aws_access_key_id}",
                        "AWS_SECRET_ACCESS_KEY=${l_aws_secret_access_key}"
                      ],
        hour        => $l_hour,
        minute      => $l_minute,
        weekday     => $l_weekday,
    }

}
