#
# == Class: duplicity::config
#
# Configure duplicity
#
class duplicity::config
(
    $ensure,
    $gpg_key_id
)
{
    class { '::duplicity::config::gnupg':
        ensure     => $ensure,
        gpg_key_id => $gpg_key_id,
    }
}
