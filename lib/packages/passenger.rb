task :passenger, 'Install passenger' do
  sudo install 'libcurl4-openssl-dev'
  run gem 'passenger', :version => AppConf.passenger.version

  AppConf.passenger.root = File.join(AppConf.user_home, AppConf.ruby.gems_path, "passenger-#{AppConf.passenger.version}")
  AppConf.passenger.ruby = File.join(AppConf.user_home, AppConf.ruby.executable)
end

