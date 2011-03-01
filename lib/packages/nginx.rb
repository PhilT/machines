download AppConf.nginx.url
extract "nginx-#{AppConf.nginx.version}.tar.gz"
add_init_d 'nginx'
template 'nginx/nginx.conf.erb', :to => File.join(AppConf.nginx.path, 'conf', 'nginx.conf')

# Belongs in a machines/lib module
require 'erb'
require 'ostruct'
class AppBuilder < OpenStruct
  def get_binding
    binding
  end
end
yaml = YAML.load(File.open('apps.yml'))
yaml.each do |app_name, app_hash|
  app = AppBuilder.new
  AppBuilder.from(app_hash)   #1st alt
  app.set_multiple(app_hash)  #2nd alt
  app.ssl_key = app_hash[AppConf.environment].ssl + '.key'
  app.ssl_crt = app_hash[AppConf.environment].ssl + '.crt'
  app_hash.each do |k, v|
    app[k] = v
  end
end
########

# Should be set at init time
AppConf.user.home = File.join('/home', AppConf.user.name)

server_name = app[AppConf.environment].server_name

def generate_template_for(app, enable_ssl = false)
  app.enable_ssl = enable_ssl
  path = File.join(AppConf.nginx.path, 'servers', "#{app.name}_#{enable_ssl ? 'ssl' : ''}.conf"
  template 'nginx/_app_server.conf.erb', :settings => app, :to => path)
end

mkdir File.join(AppConf.nginx.destination, 'app_servers', 'optional')
AppConf.apps.each do |app|
  make_app_structure app.path # check this is needed for all environments
  generate_template_for(app)
  if app.ssl_key
    generate_template_for(app, true)
    upload "certificates/#{ssl_crt}", '/etc/ssl/certs/{ssl_crt}'
    upload "certificates/#{ssl_key}", '/etc/ssl/private/#{ssl_key}'
  end
end


=begin

    if environment == 'staging' && app == 'application'
      upload "nginx/_application_basic_auth.conf", NGINX_INCLUDES + '/optional/_application_basic_auth.conf'
      upload "nginx/passwd", '/opt/nginx/passwd'
    end

    write_yaml :for => app, :to => File.join(app_root, 'shared', 'config') unless development?
#    run ["cd #{app_root}", "rake db:setup"] if development? # need workspace folders to exist
  end

=end

