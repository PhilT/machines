download AppConf.nginx.url
extract "nginx-#{AppConf.nginx.version}.tar.gz"
add_init_d 'nginx'
template 'nginx/nginx.conf.erb', :to => File.join(AppConf.nginx.path, 'conf', 'nginx.conf')

upload 'nginx/conf/htpasswd', File.join(AppConf.nginx.path, 'conf', 'htpasswd'), 400

