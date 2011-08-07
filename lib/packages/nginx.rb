task 'Download and install Nginx' do
  run extract AppConf.nginx.url
  sudo add_init_d 'nginx'
  sudo template File.join(AppConf.project_dir, 'nginx', 'nginx.conf.erb'), :to => File.join(AppConf.nginx.path, 'conf', 'nginx.conf')
end

task 'Upload htpasswd file' do
  htpasswd_file = File.join(AppConf.nginx.path, 'conf', 'htpasswd')
  sudo upload 'nginx/conf/htpasswd', htpasswd_file
  sudo chmod 400, htpasswd_file
end

