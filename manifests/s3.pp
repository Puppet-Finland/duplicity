#
# == Class: duplicity::s3
#
# Set default values for ::duplicity::backup::s3 resources and realize them as necessary. 
#
# == Parameters
#
# [*gpg_passphrase*]
#   The passphrase for the GPG key.
# [*aws_access_key_id*]
#   AWS access key. You can get this from the AWS web interface.
# [*aws_secret_access_key*]
#   AWS secret access Key. You can get this from the AWS web interface.
# [*bucket*]
#   The name of the S3 bucket to push backups to. Must be globally unique in 
#   Amazon S3.
# [*encrypt_secret_keyring*]
#   Location of the GnuPG keyring used by the encryption key. Defaults to 
#   '/root/.gnupg'. Changing this has not been tested and might not work.
# [*s3_endpoint*]
#   The Amazon S3 endpoint. Defaults to 's3.eu-central-1.amazonaws.com'. Valid 
#   values are available here:
#   
#   <http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region>
#
# [*full_interval*]
#   The interval between taking full backups. See duplicity man-page for the
#   format. Defaults to '1W'.
# [*hour*]
#   The hour when the cronjob runs. Defaults to '23'.
# [*minute*]
#   The minute when the cronjob runs. Defaults to '18'.
# [*weekday*]
#   The minute when the cronjob runs. Defaults to '*'.
# [*monthday*]
#   The day of the month when the cronjob runs. Defaults to '*'.
# [*backups*]
#   A hash of duplicity::backup::s3 resources to realize.
#
class duplicity::s3
(
    $gpg_passphrase,
    $aws_access_key_id,
    $aws_secret_access_key,
    $bucket,
    $encrypt_secret_keyring = '/root/.gnupg',
    $s3_endpoint = 's3.eu-central-1.amazonaws.com',
    $full_interval = '2W',
    $volsize = '250',
    $hour = '23',
    $minute = '18',
    $weekday = '*',
    $monthday = '*',
    $backups = {}
)
{
    include ::duplicity

    validate_string($gpg_passphrase)
    validate_string($aws_access_key_id)
    validate_string($aws_secret_access_key)
    validate_string($encrypt_secret_keyring)
    validate_string($s3_endpoint)
    validate_integer($volsize)
    validate_hash($backups)

    # Deep merge support for Hiera hashes, with fallback if not using Hiera
    $hiera_backups = hiera_hash('duplicity::s3::backups', undef)
    if $hiera_backups == undef { $l_backups = $backups } else { $l_backups = $hiera_backups }

    $backup_defaults = {'ensure' => 'present'}
    create_resources('duplicity::backup::s3', $l_backups, $backup_defaults)
}
