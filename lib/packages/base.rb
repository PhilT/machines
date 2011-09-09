task :hosts, 'Set /etc/hosts' do
  # Sets hostname according to the following: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=316099
  fqdn = AppConf.hostname
  hostname = AppConf.hostname.split('.').first
  sudo write "127.0.0.1 #{fqdn} localhost.localdomain localhost\n127.0.1.1 #{hostname}", :to => '/etc/hosts'
  only :environment => :development do
    AppConf.localhosts.each do |host|
      sudo append "127.0.0.1 #{host}", :to => '/etc/hosts'
    end
  end
  sudo write AppConf.hostname, :to => '/etc/hostname'
  sudo start 'hostname'
end

task :base, 'Install base packages' do
  sudo install %w(build-essential zlib1g-dev libpcre3-dev)
  sudo install %w(libreadline5-dev libxml2-dev libxslt1-dev libssl-dev)
end

