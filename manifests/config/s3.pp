#
# == Class: duplicity::config::s3
#
# Set default values for Amazon S3 backup resources
#
class duplicity::config::s3
(
    $encrypt_key,
    $sign_key,
    $gpg_passphrase,
    $gpg_sign_passphrase,
    $aws_access_key_id,
    $aws_secret_access_key,
    $bucket,
    $ensure = 'present',
    $full_interval = '1W',
    $encrypt_secret_keyring = '/root/.gnupg',
    $s3_endpoint = 's3.eu-central-1.amazonaws.com'
)
{
    # This class is empty, because it is only used for defining default values 
    # for duplicity::backup::s3 resources.
}
