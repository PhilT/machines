task :passenger, 'Install passenger' do
  sudo install 'libcurl4-openssl-dev'
  #HACK: PATHS are added to .profile which is not run on a non-login shell. NET::Ssh creates non-login shells
  if $conf.ruby.gems_path =~ /^.rbenv/
    run "~/.rbenv/bin/rbenv exec gem install passenger -v #{$conf.passenger.version}", "~/.rbenv/bin/rbenv exec gem list | grep passenger #{echo_result}"
  else
    run gem 'passenger', :version => $conf.passenger.version
  end

  $conf.passenger.root = File.join($conf.user_home, $conf.ruby.gems_path, "passenger-#{$conf.passenger.version}")
  $conf.passenger.ruby = File.join($conf.user_home, $conf.ruby.executable)
end

