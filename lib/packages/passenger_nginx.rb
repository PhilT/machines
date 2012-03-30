task :passenger_nginx, 'Build the passenger module for Nginx' do
  $conf.passenger.nginx = File.join($conf.passenger.root, 'ext/nginx')
  run "cd #{$conf.passenger.nginx} && rake nginx RELEASE=yes && cd -"
end

