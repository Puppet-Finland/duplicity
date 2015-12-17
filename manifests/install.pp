# == Class: duplicity::install
#
# This class installs duplicity
#
class duplicity::install
(
    $ensure

) inherits duplicity::params
{
    package { $::duplicity::params::package_name:
        ensure => $ensure,
    }
}
