task :ntpdate, 'Synchronize time daily with ntpdate' do
  sudo write 'ntpdate -s ntp.ubuntu.com pool.ntp.org', :to => '/etc/cron.daily/ntpdate'
  sudo chmod 755, '/etc/cron.daily/ntpdate'
end

