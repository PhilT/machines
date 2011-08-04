run "passenger-install-nginx-module --auto --prefix=#{AppConf.nginx.path} --nginx-source-dir=/tmp/nginx-#{AppConf.nginx.version} --extra-configure-flags=--with-http_ssl_module", check_file(File.join(AppConf.nginx.path, 'sbin', 'nginx'))

