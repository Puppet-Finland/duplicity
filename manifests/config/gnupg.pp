#
# == Class: duplicity::config::gnupg
#
# GnuPG configuration for duplicity
#
class duplicity::config::gnupg
(
    $ensure,
    $gpg_key_id
)
{
    validate_string($gpg_key_id)

    Gnupg_key {
        ensure => $ensure,
        user   => 'root',
        key_id => $gpg_key_id,
    }

    gnupg_key { 'duplicity-public-key':
        key_source => "puppet:///files/${gpg_key_id}-public.key",
        key_type   => 'public',
    }

    gnupg_key { 'duplicity-private-key':
        key_source => "puppet:///files/${gpg_key_id}-private.key",
        key_type   => 'private',
    }
}
