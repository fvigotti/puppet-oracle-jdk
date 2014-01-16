# == Fact: concat_basedir
#
# A custom fact that sets the default location for fragments
#
# "${::vardir}/concat/"
#
Facter.add(:java_version) do
  has_weight 100
  confine :kernel => "Linux"
  setcode do
    if File.exist? "/usr/java/latest/bin/java"
      java_version = Facter::Util::Resolution.exec('/usr/java/latest/bin/java -version')
      /version "([^"]*)/.match(java_version)[1]
    else
      "0"
    end

  end
end

Facter.add(:java_present) do
  has_weight 100
  confine :kernel => "Linux"
  setcode do
    File.exist? "/usr/java/latest/bin/java"
  end
end

