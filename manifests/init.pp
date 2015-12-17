# == Class: duplicity
#
# This class sets up duplicity.
#
# == Parameters
#
# [*manage*]
#   Whether to manage duplicity using Puppet. Valid values are true (default) 
#   and false.
# [*ensure*]
#   Status of duplicity. Valid values are 'present' (default) and 'absent'.
# [*gpg_key_id*]
#   The ID of the GPG key to use. Both the public and private keys are imported 
#   automatically from the Puppet fileserver. They need to named as
#   
#     <gpg_key_id>-public.key
#     <gpg_key_id>-private.key
#
# == Authors
#
# Samuli Seppänen <samuli.seppanen@gmail.com>
#
# == License
#
# BSD-license. See file LICENSE for details.
#
class duplicity
(
    $gpg_key_id,
    $manage = true,
    $ensure = 'present'

) inherits duplicity::params
{

validate_bool($manage)
validate_re("${ensure}", '^(present|absent)$')

if $manage {

    include ::duplicity::prequisites

    class { '::duplicity::install':
        ensure => $ensure,
    }

    class { '::duplicity::config':
        ensure     => $ensure,
        gpg_key_id => $gpg_key_id,
    }
}
}
