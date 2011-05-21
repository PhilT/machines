task 'Set timezone from config.yml' do
  sudo link '/etc/localtime', "/usr/share/zoneinfo/#{AppConf.timezone}"
  sudo replace 'UTC=yes', :with => 'UTC=no', :in => '/etc/default/rcS'
end

task 'Set hostname' do
  sudo write AppConf.hostname, :to => '/etc/hostname'
  sudo "hostname #{AppConf.hostname}"
end

task 'Set /etc/hosts' do
  sudo write "127.0.1.1\t#{AppConf.hostname}", :to => '/etc/hosts'
  sudo append "127.0.0.1\tlocalhost", :to => '/etc/hosts'
  only :enviroments => :development do
    hosts_config = 'config/hosts.yml'
    if File.exist?(hosts_config)
      File.readlines(hosts_config) { |host| sudo append "127.0.0.1\t#{host}", :to => '/etc/hosts' }
    end
  end
end

task 'Install base packages' do
  sudo install %w(build-essential zlib1g-dev libpcre3-dev)
  sudo install %w(libreadline5-dev libxml2-dev libxslt1-dev libssl-dev)
end

