# set time to zone specified in config.yml, set hostname, /etc/hosts and install base packages

sudo link '/etc/localtime', :to => "/usr/share/zoneinfo/#{AppConf.timezone}"
sudo replace 'UTC=yes', :with => 'UTC=no', :in => '/etc/default/rcS'

sudo write AppConf.hostname, :to => '/etc/hostname'
sudo "hostname #{AppConf.hostname}"

sudo write "127.0.1.1\t#{AppConf.hostname}", :to => '/etc/hosts'
sudo append "127.0.0.1\tlocalhost", :to => '/etc/hosts'

enviroments :development do
  hosts_config = 'config/hosts.yml'
  if File.exist?(hosts_config)
    File.readlines(hosts_config) { |host| sudo append "127.0.0.1\t#{host}" }
  end
end

sudo install %w(build-essential zlib1g-dev libpcre3-dev)
sudo install %w(libreadline5-dev libxml2-dev libxslt1-dev libssl-dev)

