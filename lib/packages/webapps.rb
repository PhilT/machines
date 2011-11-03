def create_folders app
  if AppConf.environment == :development
    run git_clone app.scm, :to => app.full_path
    run bundle app.path
  else
    %w(releases shared/config shared/system).each do |dir|
      run mkdir File.join(app.full_path, dir)
    end
    run write_database_yml :to => File.join(app.full_path, 'shared', 'config'), :for => app.name
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
  webserver = AppConf[AppConf.webserver]
  path = File.join(webserver.path, webserver.servers_dir, conf_name)
  sudo create_from "#{AppConf.webserver}/app_server.conf.erb", :settings => app, :to => path
  sudo mkdir "/var/log/#{AppConf.webserver}"
end

task :webapps, 'Sets up Web apps in config/webapps.yml using app_server.conf.erb' do
  AppConf.webapps.each do |app_name, app|
    create_folders app
    write_server_config app, false
    write_server_config app, true if app.ssl_key
  end
end

task :monit_delayed_job, 'Add monit config for each delayed_job app', :if => [:monit] do
  sudo create_from 'monit/conf.d/delayed_job.erb',
end

