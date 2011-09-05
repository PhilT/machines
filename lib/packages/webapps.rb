task :webapps, 'Sets up Web apps in config/apps.yml using app_server.conf.erb' do
  def generate_server_template_for(app, enable_ssl = false)
    app.enable_ssl = enable_ssl
    nginx = AppConf[AppConf.webserver]
    path = File.join(nginx.path, nginx.servers_dir, "#{app.name}#{enable_ssl ? '_ssl' : ''}.conf")
    sudo create_from File.join(AppConf.project_dir, AppConf.webserver, 'app_server.conf.erb'), :settings => app, :to => path
  end

  def make_app_structure where
    %w(releases shared/config shared/system).each do |dir|
      run mkdir File.join(where, dir)
    end
  end

  sudo mkdir File.join(AppConf.nginx.path, AppConf.nginx.servers_dir)
  AppConf.apps.each do |app_name, app|
    make_app_structure app.path unless AppConf.environment == :development
    generate_server_template_for(app)
    if app.ssl_key
      run generate_template_for(app, true)
      sudo upload "certificates/#{ssl_crt}", '/etc/ssl/certs/{ssl_crt}'
      sudo upload "certificates/#{ssl_key}", '/etc/ssl/private/#{ssl_key}'
    end
    run write_database_yml :to => File.join(app.path, 'shared', 'config'), :for => app_name unless AppConf.environment == :development
  end
end

