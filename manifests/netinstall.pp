define vigojava::netinstall(
$ensure        = 'present',
$source        = 'http://download.oracle.com/otn-pub/java/jdk/7u45-b18/jdk-7u45-linux-x64.rpm',
#$deploymentdir = '/tmp/oracle-java',
#$pathfile      = '/etc/bashrc',
$cachedir      = "/tmp/java_setup_working-${name}",
$user          = undef) {


  notice('entered setup')
  #"/usr/bin/wget -O /usr/java/{{ jdk.dl_filename}}  --no-check-certificate  --no-cookies --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" \"{{ jdk.dl_filepath  }}{{ jdk.dl_filename}}\""
  # We support only Debian, RedHat and Suse
  if $source =~ /.*jdk-([a-z0-9]*).*/{
    $javaVersion = "$1"
  }
  if $source =~ /.*jdk-[0-9]u([a-z0-9]*).*/{
    $jdkUpdate = "$1"
  }
  if $source =~ /.*\/(.*)/{
    $jdkFilename = "$1"
  }

  #$jdkfinder = /.*jdk-([a-z0-9]*).*/
  #$jdkVersion = jdkfinder.match($source)[1]

  #$isJavaAlreadyInstalled = "command java >/dev/null 2>&1 || { exit 1; }; echo $? /usr/java/latest/bin/java -version 2>&1 | grep '_${jdkUpdate}'"
  #$isJavaAlreadyInstalled = "([ `test -e /usr/java/latest/bin/java` ] && [ `/usr/java/latest/bin/java -version 2>&1 | grep '_${jdkUpdate}'` ]) "
  $isJavaAlreadyInstalled = ["test -e /usr/java/latest/bin/java" , "/usr/java/latest/bin/java -version 2>&1 | grep '_${jdkUpdate}'"]

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
    fail('source must be .rpm')
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


  notify {"$javaVersion = ${javaVersion} , jdkUpdate = ${jdkUpdate} , jdkFilename = ${jdkFilename} , isJavaAlreadyInstalled = ${isJavaAlreadyInstalled} ":}

  #$output = generate("/usr/bin/uptime | /usr/bin/awk '{print $3}' | cut -d, -f1")
  $output =  generate("/bin/sh", "-c", "/usr/bin/uptime | /usr/bin/awk '{print $3}' | cut -d, -f1")
  $output2 =  inline_template("<%  File.exist? '/usr/java/latest/bin/java' ? 'esiste' : 'notexistsz' %>")
  #$output3 =  $::role
  $output3 = $::java_version
  $java_version_extracted = regsubst($::java_version, '([0-9]+)', '<\1>', 'G')
  #$output2 =  inline_template("<% FileTest.exists?('/usr/java/latest/bin/java') ? 'esiste' : 'notexistsz' %>")
  #$output3 =  generate("/usr/bin/test", "-e", " /usr/java/latest/bin/java")
 $false_condition = false
  notify { "output is ${output}": } ->
  notify { "output2 is ${output2}": } ->
  notify { "output3 is ${output3}": } ->
  notify { "java_present is ${::java_present}": }

 if $::java_present == 'false' {
    notify { "java not present should be created": } ->
#    exec { "create-${cachedir}":
#    cwd     => '/',
#    command => "mkdir -p ${cachedir}",
#    creates => $cachedir,
#    onlyif => [
#    "test ! -d ${cachedir}"
#    ],
#    #unless => $::java_present,
#    #unless => $false_condition,
#    require => Notify["java_present is ${::java_present}"],
#    } ->
    file { "create-${cachedir}" :
      path => $cachedir ,
      ensure => "directory"
    } ->
    notify { "folder created ": }
    -> exec { "download JAVA rpm":
    cwd     => $cachedir,
    command => "/usr/bin/wget -O ${cachedir}/${jdkFilename}  --no-check-certificate  --no-cookies --header \"Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com\" \"${source}\"",
    unless => "test -e ${cachedir}/${jdkFilename}",
    #refreshonly => true
    #creates => "${cachedir}/.java_extracted",
    # in case of a bin archive, we get a return code of 1 from unzip. This is ok
    #returns => [0, 1],
    #require => File["${cachedir}/${source}"],
    } ->
    exec { "make as execuytable JAVA rpm":
    cwd     => $cachedir,
    command => "chmod +x ${jdkFilename}",
    }->
    exec { "install JAVA rpm":
    cwd     => $cachedir,
    command => "rpm -ivh ${jdkFilename}",
    }




  }


  #fail("stop here , $javaVersion = ${javaVersion} , ${jdkUpdate} , ${isJavaAlreadyInstalled} , ${jdkFilename}")

  } else {
#    file { $deploymentdir:
#      ensure  => absent,
#      recurse => true,
#      force   => true,
#    }

#    file { $cachedir:
#      ensure  => absent,
#      recurse => true,
#      force   => true,
#    }
  }
}
