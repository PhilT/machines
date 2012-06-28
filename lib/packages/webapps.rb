task :webapps, 'Sets up Web apps in config/webapps.yml using app_server.conf.erb. Copies SSL certs.' do
  sudo mkdir File.join($conf.webserver.path, $conf.webserver.servers_dir) if $conf.webserver.servers_dir
  $conf.webapps.each do |app_name, app|
    if $conf.environment == 'development'
      run git_clone app.scm, :to => app.path, :branch => app.branch
      bundle_command =  $conf.ruby.gems_path =~ /^.rbenv/ ? "$HOME/.rbenv/bin/rbenv exec bundle" : "bundle"
      bundle_command = "cd #{app.path} && #{bundle_command}"
      run bundle_command, check_command("#{bundle_command} check")
      run "#{bundle_command} --binstubs=.bin", check_dir("#{app.path}/.bin")
      run mkdir "#{app.path}/.bin/safe" if $conf.bin_safe
    else
      %w(releases shared/config shared/system shared/log).each do |dir|
        run mkdir File.join(app.path, dir)
      end
    end

    if app.ssl && File.exists?("certificates/#{app.ssl_crt}") && File.exists?("certificates/#{app.ssl_key}")
      webserver_conf_path = File.join $conf.webserver.path, $conf.webserver.conf_path
      sudo upload "certificates/#{app.ssl_crt}", "#{webserver_conf_path}/#{app.ssl_crt}"
      sudo upload "certificates/#{app.ssl_key}", "#{webserver_conf_path}/#{app.ssl_key}"
      sudo chmod '600', "#{webserver_conf_path}/#{app.ssl_key}"
    end
    conf_name = "#{app.name}.conf"
    conf_path = File.join($conf.webserver.path, $conf.webserver.servers_dir, conf_name)
    sudo create_from "#{$conf.webserver.name}/app_server.conf.erb", :settings => app, :to => conf_path
    sudo mkdir "/var/log/#{$conf.webserver.name}"

    run write_database_yml app if app.write_yml && $conf.environment != 'development'
    sudo append "127.0.0.1 #{app.server_name}", :to => '/etc/hosts'
  end
end

task :monit_delayed_job, 'Add monit config for each delayed_job app', :if => [:monit] do
  sudo create_from 'monit/conf.d/delayed_job.erb', :to => '/etc/monit/conf.d/delayed_job'
end

