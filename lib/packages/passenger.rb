task :passenger, 'Install passenger' do
  sudo install 'libcurl4-openssl-dev'
  #HACK: PATHS are added to .profile which is not run on a non-login shell. NET::Ssh creates non-login shells
  if $conf.ruby.gems_path =~ /^.rbenv/
    rbenv_gem = '~/.rbenv/bin/rbenv exec gem'
    run "#{rbenv_gem} install passenger -v #{$conf.passenger.version}", check_command("#{rbenv_gem} list", 'passenger')
  else
    run gem 'passenger', :version => $conf.passenger.version
  end

  $conf.passenger.root = File.join($conf.user_home, $conf.ruby.gems_path, "passenger-#{$conf.passenger.version}")
  $conf.passenger.ruby = File.join($conf.user_home, $conf.ruby.executable)
end

