task :unison, 'Install unison two way file sync and set it to run hourly. Config in users/user/.unison/default.prf' do
  sudo install 'unison'
  sudo link '/usr/bin/unison', '/etc/cron.hourly'
end

