#
# == Class: duplicity::params
#
# Defines some variables based on the operating system
#
class duplicity::params {

    case $::osfamily {
        'RedHat': {
            $package_name = 'duplicity'
        }
        'Debian': {
            $package_name = 'duplicity'
        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
