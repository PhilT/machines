run download AppConf.nginx.url
run extract "nginx-#{AppConf.nginx.version}.tar.gz"
sudo add_init_d 'nginx'
run template 'nginx/nginx.conf.erb', :to => File.join(AppConf.nginx.path, 'conf', 'nginx.conf')

htpasswd_file = File.join(AppConf.nginx.path, 'conf', 'htpasswd')
sudo upload 'nginx/conf/htpasswd', htpasswd_file
sudo chmod 400, htpasswd_file

