task :passenger_nginx, 'Build the passenger module for Nginx' do
  AppConf.passenger.nginx = File.join(AppConf.passenger.root, 'ext/nginx')
  sudo "cd #{AppConf.passenger.nginx} && rake nginx RELEASE=yes && cd -"
end
