desc 'Install Passenger and Nginx module'

install libcurl4-openssl-dev

gem 'passenger', :version => Config.passenger.version, :as => Config.user.name

run "rvmsudo passenger-install-nginx-module --auto --prefix=#{Config.nginx.destination} --nginx-source-dir=/tmp/nginx-#{Config.nginx.version} --extra-configure-flags=--with-http_ssl_module", :check => check_file(File.join(Config.nginx.destination, 'sbin', 'nginx')), :as => Config.user.name

