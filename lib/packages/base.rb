task :hosts, 'Setup /etc/hosts' do
  # Sets hostname according to the following: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=316099
  fqdn = $conf.machine.hostname
  hostname = $conf.machine.hostname.split('.').first
  sudo write "127.0.0.1 #{fqdn} localhost.localdomain localhost\n127.0.1.1 #{hostname}\n", :to => '/etc/hosts'
  sudo write $conf.machine.hostname, :to => '/etc/hostname'
  sudo start 'hostname', :check => false

  $conf.hosts.to_hash.each do |host, address|
    sudo append "#{address} #{host}", :to => '/etc/hosts'
  end if $conf.hosts
end


task :base, 'Install base packages' do
  sudo install %w(build-essential zlib1g-dev libpcre3-dev libruby1.9.1)
  sudo install %w(libxml2-dev libxslt1-dev libssl-dev)
end

