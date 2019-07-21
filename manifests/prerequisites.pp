#
# == Class: duplicity::prerequisites
#
# Setup prerequisites for duplicity. Note that prerequisites are not removed
# even if you pass "ensure => absent" to the main class.
#
class duplicity::prerequisites inherits duplicity::params {

    include ::gnupg
}
