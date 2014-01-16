# == Fact: concat_basedir
#
# A custom fact that sets the default location for fragments
#
# "${::vardir}/concat/"
#
Facter.add(:role) do
  has_weight 100
  confine :kernel => "Linux"
  setcode do
    if File.exist? "/etc/postgres_server"
      "postgres_server"
    end
  end
end

# Guess if this is a server by the presence of the pg_create binary
Facter.add(:role) do
  has_weight 50
  confine :kernel => "Linux"
  setcode do
    if File.exist? "/usr/sbin/pg_create"
      "postgres_server"
    end
  end
end


# Guess if this is a server by the presence of the pg_create binary
Facter.add(:role) do
  has_weight 40
  setcode do
      "default_40"
  end
end

# Guess if this is a server by the presence of the pg_create binary
Facter.add(:role) do
  has_weight 30
  setcode do
      "default1"
  end
end

Facter.add(:role) do
  has_weight 20
  setcode do
    "default2"
  end
end
