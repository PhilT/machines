download AppConf.nginx.url
extract "nginx-#{AppConf.nginx.version}.tar.gz"
add_init_d 'nginx'
template 'nginx/nginx.conf.erb', :to => File.join(AppConf.nginx.path, 'conf', 'nginx.conf')


# WIP
app 'application', :ssl => true, %w()
app 'velocity', 'todo.local', 'todo.puresolo.com'
app 'fountain',

#Test OpenStruct with ERB
require 'erb'
require 'ostruct'
class AppBuilder < OpenStruct
  def get_binding
    binding
  end
end
app = AppBuilder.new
app.name = 'something'
erb = ERB.new("<%= name %>")
erb.result(app.get_binding)
###

# Should be set at init time
AppConf.user.home = File.join('/home', AppConf.user.name)

server_name = app[AppConf.environment].server_name


mkdir File.join(AppConf.nginx.destination, 'app_servers', 'optional')
AppConf.apps.each do |app|
  make_app_structure app.path # check this is needed for all environments
  template 'nginx/_server.conf.erb', :settings => AppConf[app_name].app, :to => File.join(AppConf.nginx.path, 'servers', "#{app.name}.conf")
  if app.enable_ssl
    app.ssl = true
    template 'nginx/_server.conf.erb', :settings => app, :to => File.join(AppConf.nginx.path, 'servers', "#{app.name}_ssl.conf")
  end
end


=begin

  apps.each do |app|
    builder = ServerBuilder.new [app_config[app][environment], "#{app_root}/public", environment, 'puresolo.com.crt', 'puresolo.com.key', app]
    result = erb.result(builder.get_binding)
    if app == 'application'
      builder.ssl = true
      result += erb.result(builder.get_binding)
    end
    append result, :to => File.join(NGINX_INCLUDES, app + ".conf")

    if environment == 'staging' && app == 'application'
      upload "nginx/_application_basic_auth.conf", NGINX_INCLUDES + '/optional/_application_basic_auth.conf'
      upload "nginx/passwd", '/opt/nginx/passwd'
    end

    write_yaml :for => app, :to => File.join(app_root, 'shared', 'config') unless development?
#    run ["cd #{app_root}", "rake db:setup"] if development? # need workspace folders to exist
  end

=end

