desc 'Install Passenger Nginx module'

run "passenger-install-nginx-module --auto --prefix=#{AppConf.nginx.destination} --nginx-source-dir=/tmp/nginx-#{AppConf.nginx.version} --extra-configure-flags=--with-http_ssl_module", :check => check_file(File.join(AppConf.nginx.destination, 'sbin', 'nginx')), :as => AppConf.user.name

