def create_folders app
  if AppConf.environment == :development
    run git_clone app.scm, :to => app.full_path
    run bundle app.full_path
  else
    %w(releases shared/config shared/system).each do |dir|
      run mkdir File.join(app.full_path, dir)
    end
  end
end

def write_server_config(app, enable_ssl)
  app.enable_ssl = enable_ssl
  if enable_ssl
    conf_name = "#{app.name}_ssl.conf"
    sudo upload "certificates/#{app.ssl_crt}", '/etc/ssl/certs/#{app.ssl_crt}'
    sudo upload "certificates/#{app.ssl_key}", '/etc/ssl/private/#{app.ssl_key}'
  else
    conf_name = "#{app.name}.conf"
  end
  path = File.join(AppConf.webserver.path, AppConf.webserver.servers_dir, conf_name)
  sudo create_from "#{AppConf.webserver.name}/app_server.conf.erb", :settings => app, :to => path
  sudo mkdir "/var/log/#{AppConf.webserver.name}"
end

task :webapps, 'Sets up Web apps in config/webapps.yml using app_server.conf.erb' do
  sudo mkdir File.join(AppConf.webserver.path, AppConf.webserver.servers_dir) if AppConf.webserver.servers_dir
  AppConf.webapps.each do |app_name, app|
    create_folders app
    write_server_config app, false
    write_server_config app, true if app.ssl_key
  end
end

task :monit_delayed_job, 'Add monit config for each delayed_job app', :if => [:monit] do
  sudo create_from 'monit/conf.d/delayed_job.erb', :to => '/etc/monit/conf.d/delayed_job'
end

