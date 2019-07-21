#
# == Class: duplicity::prerequisites
#
# Setup prerequisites for duplicity. Note that prerequisites are not removed
# even if you pass "ensure => absent" to the main class.
#
class duplicity::prerequisites inherits duplicity::params {

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
