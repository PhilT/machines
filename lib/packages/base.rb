task :hosts, 'Set /etc/hosts' do
  # Sets hostname according to the following: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=316099
  fqdn = AppConf.hostname
  hostname = AppConf.hostname.split('.').first
  sudo write "127.0.0.1 #{fqdn} localhost.localdomain localhost\n127.0.1.1 #{hostname}\n", :to => '/etc/hosts'
  sudo write AppConf.hostname, :to => '/etc/hostname'
  sudo start 'hostname'

  AppConf.hosts.each {|ip_host| sudo append "#{ip_host}", :to => '/etc/hosts' } if AppConf.hosts.is_a?(Array)
end


task :base, 'Install base packages' do
  sudo install %w(build-essential zlib1g-dev libpcre3-dev)
  sudo install %w(libreadline5-dev libxml2-dev libxslt1-dev libssl-dev)
end

