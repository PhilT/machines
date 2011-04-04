# Sets up the Webserver Applications configured in `config/apps.yml` using `<webserver>/app_server.conf.erb` template
# including SSL, database.yml and capistrano style releases/shared directory structure

def generate_template_for(app, enable_ssl = false)
  app.enable_ssl = enable_ssl
  path = File.join(AppConf[AppConf.webserver].path, AppConf.app_servers, "#{app.name}_#{enable_ssl ? 'ssl' : ''}.conf")
  template File.join(AppConf.webserver, 'app_server.conf.erb'), :settings => app, :to => path
end

def make_app_structure where
  %w(releases shared/config shared/system).each do |dir|
    run mkdir File.join(where, dir)
  end
end

run mkdir File.join(AppConf.nginx.path, AppConf.nginx.app_servers)
AppConf.apps.each do |app|
  make_app_structure app.path # check this is needed for all environments
  run generate_template_for(app)
  if app.ssl_key
    run generate_template_for(app, true)
    sudo upload "certificates/#{ssl_crt}", '/etc/ssl/certs/{ssl_crt}'
    sudo upload "certificates/#{ssl_key}", '/etc/ssl/private/#{ssl_key}'
  end
  run write_database_yml app, File.join(app.path, 'shared', 'config')
end

