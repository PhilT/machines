task :passenger, 'Install passenger' do
  sudo install 'libcurl4-openssl-dev'
  run gem 'passenger', :version => $conf.passenger.version

  $conf.passenger.root = File.join($conf.user_home, $conf.ruby.gems_path, "passenger-#{$conf.passenger.version}")
  $conf.passenger.ruby = File.join($conf.user_home, $conf.ruby.executable)
end

