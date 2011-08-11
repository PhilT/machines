task :passenger, 'Install passenger' do
  sudo install 'libcurl4-openssl-dev'
  run gem 'passenger', :version => AppConf.passenger.version
end

