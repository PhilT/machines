task :nginx, 'Download and configure Nginx' do
  run extract AppConf.nginx.url
  sudo add_upstart 'nginx',
    :description => 'Nginx HTTP Server',
    :start => 'on filesystem',
    :stop => 'on runlevel [!2345]',
    :respawn => true,
    :exec => "#{AppConf.nginx.path}/sbin/nginx -g \"daemon off;\""
  sudo mkdir File.join(AppConf.nginx.path, 'conf')
  sudo mkdir File.join(AppConf.nginx.path, AppConf.nginx.servers_dir) if AppConf.nginx.servers_dir
  sudo create_from 'nginx/nginx.conf.erb', :to => "#{AppConf.nginx.path}/conf/nginx.conf"
end

only :environment => :staging do
  task :htpasswd, 'Upload htpasswd file' do
    htpasswd_file = File.join(AppConf.nginx.path, 'conf', 'htpasswd')
    sudo upload 'nginx/conf/htpasswd', htpasswd_file
    sudo chmod 400, htpasswd_file
  end
end

task :monit_nginx, 'Add monit configuration for Nginx', :if => [:monit, :nginx] do
  sudo upload 'monit/conf.d/nginx', '/etc/monit/conf.d/nginx'
end

