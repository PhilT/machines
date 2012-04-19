task :passenger_nginx, 'Build the passenger module for Nginx' do
  $conf.passenger.nginx = File.join($conf.passenger.root, 'ext/nginx')
  rake_command = 'rake'
  rake_command = '~/.rbenv/bin/rbenv exec rake' if $conf.ruby.gems_path =~ /^.rbenv/
  check = check_command("ls #{$conf.passenger.root}/ext/ruby/ruby-#{$conf.ruby.version}*", 'passenger_native_support.so')
  run "cd #{$conf.passenger.nginx} && #{rake_command} nginx RELEASE=yes && cd -", check
end

