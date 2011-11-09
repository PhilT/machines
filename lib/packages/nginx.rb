task :nginx, 'Download and configure Nginx' do
  run extract AppConf.webserver.url
  sudo add_upstart 'nginx',
    :description => 'Nginx HTTP Server',
    :start => 'on filesystem',
    :stop => 'on runlevel [!2345]',
    :respawn => true,
    :exec => "#{AppConf.webserver.path}/sbin/nginx -g \"daemon off;\"",
    :env => 'PID=/opt/nginx/logs/nginx.pid',
    :post_stop => 'start-stop-daemon --stop --pidfile $PID --name nginx --exec $DAEMON --signal TERM'
  sudo mkdir File.join(AppConf.webserver.path, 'conf')
  sudo create_from 'nginx/nginx.conf.erb', :to => "#{AppConf.webserver.path}/conf/nginx.conf"
end

only :environment => :staging do
  task :htpasswd, 'Upload htpasswd file' do
    htpasswd_file = File.join(AppConf.webserver.path, 'conf', 'htpasswd')
    sudo upload 'nginx/conf/htpasswd', htpasswd_file
    sudo chmod 400, htpasswd_file
  end
end

task :monit_nginx, 'Add monit configuration for Nginx', :if => [:monit, :nginx] do
  sudo upload 'monit/conf.d/nginx', '/etc/monit/conf.d/nginx'
end

