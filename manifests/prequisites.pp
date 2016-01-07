#
# == Class: duplicity::prequisites
#
# Setup prequisites for duplicity. Note that prequisites are not removed even if 
# you pass "ensure => absent" to the main class.
#
class duplicity::prequisites inherits duplicity::params {
    include ::gnupg

    if $::duplicity::params::use_pip_boto {
        class { '::python::boto':
            provider => 'pip',
            version  => $::duplicity::params::known_good_boto_version,
        }

    } else {
        include ::python::boto
    }
}
