define vigojava::setup(
$ensure        = 'present',
$source        = undef,
$deploymentdir = '/tmp/oracle-java',
$pathfile      = '/etc/bashrc',
$cachedir      = "/var/run/puppet/java_setup_working-${name}",
$user          = undef) {

  notice('JAVA NETINSTALL START ')
  #"/usr/bin/wget -O /usr/java/{{ jdk.dl_filename}}  --no-check-certificate  --no-cookies --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" \"{{ jdk.dl_filepath  }}{{ jdk.dl_filename}}\""
  # We support only Debian, RedHat and Suse
  case $::osfamily {
    #Debian  : { $supported = true }
    RedHat  : { $supported = true }
    #Suse    : { $supported = true }
    default : { fail("The ${module_name} module is not supported on ${::osfamily} based systems") }
  }

  # Validate parameters
  if ($source == undef) {
    fail('source parameter must be set')
  }

  if ($user == undef) {
    fail('user parameter must be set')
  }

  # Validate source is .gz or .tar.gz
  #if !(('.tar.gz' in $source) or ('.gz' in $source) or ('.bin' in $source)) {
  if !(('.rpm' in $source)) {
    fail('source must be .rpm file ')
  }

  # Validate input values for $ensure
  if !($ensure in ['present', 'absent']) {
    fail('ensure must either be present or absent')
  }

  if ($caller_module_name == undef) {
    $mod_name = $module_name
  } else {
    $mod_name = $caller_module_name
  }

  # Resource default for Exec
  Exec {
    path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin'], }

  # When ensure => present
  if ($ensure == 'present') {



  exec { "java already present":
    command => "touch /tmp/java_to_install",
    unless => "/usr/java/latest/bin/java -version 2>&1 | grep '_45'",
    #creates => "${cachedir}/.java_extracted",
    # in case of a bin archive, we get a return code of 1 from unzip. This is ok
    #returns => [0, 1],
    require => File["${cachedir}/${source}"],

  } /*-> notify {"notifing java already present  : ${cachedir}/${source} ":}
   ->
  exec { "java already present _test1":
    command => "touch /tmp/java_to_install_test1",
      subscribe => Exec["java already present"],
      refreshonly => true
  } */ -> notify {"notifing creation of  _test1":}




    exec { "create-${cachedir}":
      cwd     => '/',
      command => "mkdir -p ${cachedir}",
      creates => $cachedir,
      unless => "/usr/java/latest/bin/java -version 2>&1 | grep '_45'",
    } -> notify {" folder is present  ${cachedir} ":}




    file { "${cachedir}/${source}":
      source  => "puppet:///modules/${mod_name}/${source}",
      mode    => '711',

      #checksum => "none",
      require => Exec["create-${cachedir}"],
    }

    if ('.rpm' in $source) {
      exec { "extract_java-${name}":
        cwd     => $cachedir,
        # command => "mkdir extracted; cd extracted ;  ../*.bin  <> echo '\n\n' -d extracted && touch ${cachedir}/.java_extracted",
        command => "rpm -ivh ${source}",
        unless => "/usr/java/latest/bin/java -version 2>&1 | grep '_45'",
        #creates => "${cachedir}/.java_extracted",
        # in case of a bin archive, we get a return code of 1 from unzip. This is ok
        #returns => [0, 1],
        require => File["${cachedir}/${source}"],


      } -> notify {"FILE CREATED : ${cachedir}/${source} ":}
    }

    /*else {
      exec { "extract_java-${name}":
        cwd     => $cachedir,
        command => "mkdir extracted; tar -C extracted -xzf *.gz && touch ${cachedir}/.java_extracted",
        creates => "${cachedir}/.java_extracted",
        require => File["${cachedir}/${source}"],
      }
    }

    exec { "create_target-${name}":
      cwd     => '/',
      command => "mkdir -p ${deploymentdir}",
      creates => $deploymentdir,
      require => Exec["extract_java-${name}"],
    }

    exec { "move_java-${name}":
      cwd     => "${cachedir}/extracted",
      command => "cp -r * ${deploymentdir}/ && chown -R ${user}:${user} ${deploymentdir} && touch ${deploymentdir}/.puppet_java_${name}_deployed",
      creates => "${deploymentdir}/.puppet_java_${name}_deployed",
      require => Exec["create_target-${name}"],
    }

    exec { "set_java_home-${name}":
      cwd     => '/',
      command => "echo 'export JAVA_HOME=${deploymentdir}' >> ${pathfile}",
      unless  => "grep 'JAVA_HOME=${deploymentdir}' ${pathfile}",
      require => Exec["move_java-${name}"],
    }

    exec { "update_path-${name}":
      cwd     => '/',
      command => "echo 'export PATH=\$JAVA_HOME/bin:\$PATH' >> ${pathfile}",
      unless  => "grep 'export PATH=\$JAVA_HOME/bin:\$PATH' ${pathfile}",
      require => Exec["set_java_home-${name}"],
    }

    exec { "update_classpath-${name}":
      cwd     => '/',
      command => "echo 'export CLASSPATH=\$JAVA_HOME/lib/classes.zip' >> ${pathfile}",
      unless  => "grep 'export CLASSPATH=\$JAVA_HOME/lib/classes.zip' ${pathfile}",
      require => Exec["set_java_home-${name}"],
    }*/
  } else {
    file { $deploymentdir:
      ensure  => absent,
      recurse => true,
      force   => true,
    }

    file { $cachedir:
      ensure  => absent,
      recurse => true,
      force   => true,
    }
  }
}
