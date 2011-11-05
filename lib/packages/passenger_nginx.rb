task :passenger_nginx, 'Install Passenger Nginx module' do
  file_check = check_file(File.join(AppConf.nginx.path, 'sbin', 'nginx'))
  prefix = "--prefix=#{AppConf.nginx.path}"
  source_dir = "--nginx-source-dir=/tmp/nginx-#{AppConf.nginx.version}"
  flags = "--extra-configure-flags=--with-http_ssl_module"
  run "echo #{AppConf.password} | rvmsudo -S passenger-install-nginx-module --auto #{prefix} #{source_dir} #{flags}", file_check
end

