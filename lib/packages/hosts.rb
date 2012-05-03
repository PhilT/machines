task :hosts, 'Setup /etc/hosts' do
  # Sets hostname according to the following: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=316099
  fqdn = $conf.machine.hostname
  hostname = $conf.machine.hostname.split('.').first
  sudo write "127.0.0.1 #{fqdn} localhost.localdomain localhost\n127.0.1.1 #{hostname}\n", :to => '/etc/hosts'
  sudo write $conf.machine.hostname, :to => '/etc/hostname'
  sudo start 'hostname', :check => check_command('hostname', $conf.machine.hostname)

  $conf.hosts.to_hash.each do |host, address|
    sudo append "#{address} #{host}", :to => '/etc/hosts'
  end if $conf.hosts
end

