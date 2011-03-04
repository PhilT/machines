download AppConf.nginx.url
extract "nginx-#{AppConf.nginx.version}.tar.gz"
add_init_d 'nginx'
template 'nginx/nginx.conf.erb', :to => File.join(AppConf.nginx.path, 'conf', 'nginx.conf')
upload 'nginx/conf', File.join(AppConf.nginx.path, 'conf'), :owner => UserConf.user.name, :perms => 400

