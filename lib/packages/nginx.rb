task :nginx, 'Download and configure Nginx' do
  run extract AppConf.nginx.url
  sudo add_init_d 'nginx'
  sudo mkdir File.join(AppConf.nginx.path, 'conf')
  nginx_conf_erb = File.join(AppConf.project_dir, 'nginx', 'nginx.conf.erb')
  nginx_conf = File.join(AppConf.nginx.path, 'conf', 'nginx.conf')
  sudo create_from nginx_conf_erb, :to => nginx_conf
end

only :environment => :staging do
  task :htpasswd, 'Upload htpasswd file' do
    htpasswd_file = File.join(AppConf.nginx.path, 'conf', 'htpasswd')
    sudo upload 'nginx/conf/htpasswd', htpasswd_file
    sudo chmod 400, htpasswd_file
  end
end

