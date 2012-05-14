def create_folders app
  if $conf.environment == 'development'
    run git_clone app.scm, :to => app.path, :branch => app.branch
    bundle_command =  $conf.ruby.gems_path =~ /^.rbenv/ ? "$HOME/.rbenv/bin/rbenv exec bundle" : "bundle"
    run "cd #{app.path} && #{bundle_command}", "cd #{app.path} && #{bundle_command} check #{echo_result}"
    run "cd #{app.path} && #{bundle_command} --binstubs=.bin", check_dir("#{app.path}/.bin")
    run "$HOME/.rbenv/bin/rbenv rehash", check_command('echo $?', '0') if $conf.ruby.gems_path =~ /^.rbenv/
  else
    %w(releases shared/config shared/system shared/log).each do |dir|
      run mkdir File.join(app.path, dir)
    end
  end
end

def write_server_config(app, enable_ssl)
  app.enable_ssl = enable_ssl
  if enable_ssl
    conf_name = "#{app.name}_ssl.conf"
    sudo upload "certificates/#{app.ssl_crt}", "/usr/local/nginx/conf/#{app.ssl_crt}"
    sudo upload "certificates/#{app.ssl_key}", "/usr/local/nginx/conf/#{app.ssl_key}"
  else
    conf_name = "#{app.name}.conf"
  end
  path = File.join($conf.webserver.path, $conf.webserver.servers_dir, conf_name)
  sudo create_from "#{$conf.webserver.name}/app_server.conf.erb", :settings => app, :to => path
  sudo mkdir "/var/log/#{$conf.webserver.name}"
end

task :webapps, 'Sets up Web apps in config/webapps.yml using app_server.conf.erb' do
  sudo mkdir File.join($conf.webserver.path, $conf.webserver.servers_dir) if $conf.webserver.servers_dir
  $conf.webapps.each do |app_name, app|
    create_folders app
    write_server_config app, false
    write_server_config app, true if app.ssl_key
    except(:environment => :development) { run write_database_yml app }
    sudo append "127.0.0.1 #{app.server_name}", :to => '/etc/hosts'
  end
end

task :monit_delayed_job, 'Add monit config for each delayed_job app', :if => [:monit] do
  sudo create_from 'monit/conf.d/delayed_job.erb', :to => '/etc/monit/conf.d/delayed_job'
end

