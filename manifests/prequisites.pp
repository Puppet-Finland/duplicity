#
# == Class: duplicity::prequisites
#
# Setup prequisites for duplicity. Note that prequisites are not removed even if 
# you pass "ensure => absent" to the main class.
#
class duplicity::prequisites inherits duplicity::params {
    include ::gnupg
    include ::python::boto
}
