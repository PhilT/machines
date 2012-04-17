task :unison, 'Install unison two way file sync and set it to run hourly. Config in users/user/.unison/default.prf' do
  sudo install 'unison'
  run "echo '30 18 * * * /usr/bin/unison' | crontab", check_command('crontab -l', 'unison')
end

