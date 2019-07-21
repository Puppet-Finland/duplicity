#
# == Class: duplicity::config::gnupg
#
# GnuPG configuration for duplicity
#
class duplicity::config::gnupg
(
    Enum['present','absent'] $ensure,
    String                   $gpg_key_id
)
{

    $gnupg_defaults = {
        'ensure' => $ensure,
        'user'   => 'root',
        'key_id' => $gpg_key_id,
    }

    gnupg_key { 'duplicity-public-key':
        key_source => "puppet:///files/${gpg_key_id}-public.key",
        key_type   => 'public',
        *          => $gnupg_defaults,
    }

    gnupg_key { 'duplicity-private-key':
        key_source => "puppet:///files/${gpg_key_id}-private.key",
        key_type   => 'private',
        *          => $gnupg_defaults,
    }
}
