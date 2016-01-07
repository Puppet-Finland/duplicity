#
# == Class: duplicity::params
#
# Defines some variables based on the operating system
#
class duplicity::params {

    # Old versions of Boto do not work correctly with Duplicity + S3, because 
    # they only support old-style S3 URLs. European S3 buckets in particular 
    # only support new style URL. Here we define a known good version of the 
    # Boto library for use with the pip provider.
    $known_good_boto_version = '2.38.0'

    case $::osfamily {
        'RedHat': {
            $package_name = 'duplicity'
        }
        'Debian': {
            $package_name = 'duplicity'

            # We only use the pip package provider for Boto if the operating 
            # system packages are too old.
            $use_pip_boto = $::lsbdistcodename ? {
                'trusty' => true,
                default  => false,
            }

        }
        default: {
            fail("Unsupported OS: ${::osfamily}")
        }
    }
}
