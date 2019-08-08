#
# == Class: duplicity::config
#
# Configure duplicity
#
class duplicity::config
(
    Enum['present','absent'] $ensure,
    String                   $gpg_key_id,
    Optional[String]         $gpg_public_key_content,
    Optional[String]         $gpg_private_key_content,
    Optional[String]         $gpg_public_key_source,
    Optional[String]         $gpg_private_key_source,
)
{
    class { '::duplicity::config::gnupg':
        ensure                  => $ensure,
        gpg_key_id              => $gpg_key_id,
        gpg_public_key_content  => $gpg_public_key_content,
        gpg_private_key_content => $gpg_private_key_content,
        gpg_public_key_source   => $gpg_public_key_source,
        gpg_private_key_source  => $gpg_private_key_source,
    }
}
