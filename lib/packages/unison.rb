task :unison, 'Install unison two way file sync and set it to run hourly. Config in users/user/.unison/default.prf' do
  sudo install 'unison'
  run "'30 18 * * * /usr/bin/unison' | crontab", 'crontab -l | grep unison'
end

