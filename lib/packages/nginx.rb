task :nginx, 'Download and configure Nginx' do
  sudo extract $conf.webserver.url
  sudo "cd #{$conf.webserver.src_path} && ./configure #{$conf.webserver.modules} --add-module=#{$conf.passenger.nginx} && make && make install"

  sudo create_from 'nginx/nginx.conf.erb', :to => "#{$conf.webserver.path}/conf/nginx.conf"
  only(:environment => :development) { sudo create_from 'nginx/upstart.conf.erb', :to => "/etc/init/nginx.conf" }
end

only :environment => :staging do
  task :htpasswd, 'Upload htpasswd file' do
    htpasswd_file = File.join($conf.webserver.path, 'conf', 'htpasswd')
    sudo upload 'nginx/conf/htpasswd', htpasswd_file
    sudo chmod 400, htpasswd_file
  end
end

task :monit_nginx, 'Add monit configuration for Nginx', :if => [:monit, :nginx] do
  sudo upload 'monit/conf.d/nginx', '/etc/monit/conf.d/nginx'
end

