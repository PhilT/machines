task :timezone, 'Set timezone from config.yml' do
  sudo link '/etc/localtime', "/usr/share/zoneinfo/#{AppConf.timezone}"
  sudo replace 'UTC=yes', :with => 'UTC=no', :in => '/etc/default/rcS'
end

