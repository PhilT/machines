task :hosts, 'Set /etc/hosts' do
  # Sets hostname according to the following: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=316099
  sudo write "127.0.0.1 localhost.localdomain localhost\n127.0.1.1 #{AppConf.hostname}", :to => '/etc/hosts'
  only :enviroments => :development do
    hosts_config = 'config/hosts.yml'
    if File.exist?(hosts_config)
      File.readlines(hosts_config) { |host| sudo append "127.0.0.1 #{host}", :to => '/etc/hosts' }
    end
  end
  sudo write AppConf.hostname, :to => '/etc/hostname'
  sudo start 'hostname'
end

task :base, 'Install base packages' do
  sudo install %w(build-essential zlib1g-dev libpcre3-dev debconf-utils)
  sudo install %w(libreadline5-dev libxml2-dev libxslt1-dev libssl-dev)
end

