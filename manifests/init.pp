# Class: java
#
# The Java module allows Puppet to install the JDK/JRE
# and update the bashrc file to include java in the path.
#
# Provides: java::setup resource definition
#
# Parameters: ensure, source, deploymentdir, user, pathfile
#
# Sample Usage:
#    java::setup { "example.com-jdk_6u35":
#      ensure        => 'present',
#      source        => 'jdk-6u35-linux-x64.tar.gz',
#      deploymentdir => '/home/example.com/apps/jdk-6u35',
#      user          => 'example.com',
#      pathfile      => '/home/example.com/.bashrc'
#    }
#
# Refer to the module README for documentation
#
class vigojava (
$customvar  = "test"
) {
notice('executing vigojava main')
  #test
}


