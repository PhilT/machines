require 'erb'
require 'ostruct'
class AppBuilder < OpenStruct
  def get_binding
    binding
  end
end

AppConf.user.home = File.join('/home', AppConf.user.name)

yaml = YAML.load(File.open('apps.yml'))
AppConf.apps = []
yaml.each do |app_name, app_hash|
  app = AppBuilder.new
  app.name = app_name
  app.path = File.join(AppConf.appsroot, app.path)
  app.ssl_key = app_hash[AppConf.environment].ssl + '.key'
  app.ssl_crt = app_hash[AppConf.environment].ssl + '.crt'
  app_hash.each do |k, v|
    app[k] = v unless v.is_a?(Hash)
  end

  app_hash[AppConf.environment].each do |k, v|
    app[k] = v
  end
  AppConf.apps << app
end

def generate_template_for(app, enable_ssl = false)
  app.enable_ssl = enable_ssl
  path = File.join(AppConf[AppConf.webserver].path, AppConf.app_servers, "#{app.name}_#{enable_ssl ? 'ssl' : ''}.conf"
  template File.join(AppConf.webserver, 'app_server.conf.erb'), :settings => app, :to => path)
end

# Create capistrano style directory structure for the application (releases, shared/config and shared/system)
# @param [String] where Path to create the folders in
def make_app_structure where
  %w(releases shared/config shared/system).each do |dir|
    mkdir File.join(where, dir), :owner => AppConf.user.name
  end
end

mkdir File.join(AppConf.nginx.path, AppConf.app_servers)
AppConf.apps.each do |app|
  make_app_structure app.path # check this is needed for all environments
  generate_template_for(app)
  if app.ssl_key
    generate_template_for(app, true)
    upload "certificates/#{ssl_crt}", '/etc/ssl/certs/{ssl_crt}'
    upload "certificates/#{ssl_key}", '/etc/ssl/private/#{ssl_key}'
  end
  write_database_yml app, File.join(app.path, 'shared', 'config')
end

