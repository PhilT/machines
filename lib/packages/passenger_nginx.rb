task :passenger_nginx, 'Install Passenger Nginx module' do
  file_check = check_file(File.join(AppConf.webserver.path, 'sbin', 'nginx'))
  prefix = "--prefix=#{AppConf.webserver.path}"
  source_dir = "--nginx-source-dir=/tmp/nginx-#{AppConf.webserver.version}"
  flags = "--extra-configure-flags=--with-http_ssl_module"
  run "echo #{AppConf.password} | rvmsudo -S passenger-install-nginx-module --auto #{prefix} #{source_dir} #{flags}", file_check
end

