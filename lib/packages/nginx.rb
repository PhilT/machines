task :nginx, 'Download and configure Nginx' do
  sudo extract $conf.webserver.url
  modules = "#{$conf.webserver.modules} --add-module=#{$conf.passenger.nginx}"
  commands = [
    "cd #{$conf.webserver.src_path}",
    "./configure #{modules}",
    "make",
    "make install"
  ].join(' && ')


  sudo commands, check_file("#{$conf.webserver.path}/sbin/nginx")

  sudo create_from 'nginx/nginx.conf.erb', :to => "#{$conf.webserver.path}/#{$conf.webserver.conf_path}/nginx.conf"

  sudo create_from 'nginx/upstart.conf.erb', :to => "/etc/init/nginx.conf"
end

task :monit_nginx, 'Add monit configuration for Nginx', :if => [:monit, :nginx] do
  sudo upload 'monit/conf.d/nginx', '/etc/monit/conf.d/nginx'
end

