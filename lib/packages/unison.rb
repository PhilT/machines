task :unison, "Install and configure Unison (users/#{$conf.machine.user}/.unison/default.prf)" do
  sudo install 'unison'
  run "echo '30 18 * * * /usr/bin/unison' | crontab", check_command('crontab -l', 'unison')
end

