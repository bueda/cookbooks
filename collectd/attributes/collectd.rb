collectd Mash.new unless attribute?("collectd")
collectd[:base_dir] = "/var/lib/collectd" unless collectd.has_key?(:base_dir)
collectd[:plugin_dir] = "/usr/lib/collectd" unless collectd.has_key?(:plugin_dir)
collectd[:types_db] = ["/usr/lib/collectd/types.db", "/etc/collectd/my_types.db"] unless collectd.has_key?(:types_db)
collectd[:interval] = 10 unless collectd.has_key?(:interval)
collectd[:read_threads] = 5 unless collectd.has_key?(:read_threads)
collectd[:server_address] = %w(192.168.1.153 192.168.1.159)
collectd[:server] = false unless collectd.has_key?(:server)

if !collectd.has_key?(:plugins)
  collectd[:plugins] =
    [
     { "name" => "syslog", "options" => [{ "LogLevel" => "Info"  }]},
     { "name" => "cpu" },
     { "name" => "df", "options" => [{ "Device" => "/dev/vda1" }, { "Device" => "/dev/sda1" }]},
     { "name" => "disk", "options" => [{ "Disk" => "vda1" }, { "Disk" => "sda1" }]},
     { "name" => "interface", "options" => [{ "Interface" => "eth0" }, { "Interface" => "eth1"}]},
     { "name" => "memory" },
     { "name" => "rrdtool", "options" => [{ "DataDir" => "/var/lib/collectd/rrd" }, { "CacheFlush" => 120 }, { "WritesPerSecond" => 75 }]},
     { "name" => "swap" }
    ];
end
