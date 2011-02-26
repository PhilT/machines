download Config.nginx.url
extract "nginx-#{Config.nginx.version}.tar.gz"
add_init_d 'nginx'
template 'nginx/nginx.conf', :to => File.join(Config.nginx.destination, 'conf', 'nginx.conf')

