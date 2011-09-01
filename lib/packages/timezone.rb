task :timezone, 'Set timezone from config.yml and update time daily using NTP' do
  sudo link '/etc/localtime', "/usr/share/zoneinfo/#{AppConf.timezone}"
  sudo replace 'UTC=yes', :with => 'UTC=no', :in => '/etc/default/rcS'
  sudo write 'ntpdate -s ntp.ubuntu.com pool.ntp.org', :to => '/etc/cron.daily/ntpdate'
  sudo chmod 755, '/etc/cron.daily/ntpdate'
end

