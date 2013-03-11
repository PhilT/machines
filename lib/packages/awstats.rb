task :awstats, 'Install AWStats' do
  sudo install 'awstats'
  remote_file = 'https://raw.github.com/PhilT/bin/master/awstats_render'
  local_file = '/usr/local/bin/awstats_render'
  sudo "wget #{remote_file} -O #{local_file}", check_file(local_file)
  sudo chmod '+x', local_file

  $conf.webapps.each do |app_name, app|
    stats_path = "/etc/awstats/awstats.#{app.server_name}.conf"
    sudo create_from 'misc/awstats.conf.erb', settings: app,  to: stats_path
    app_stats = "#{$conf.approots}/#{app_name}_stats"
    run mkdir "#{app_stats}/data"
    run mkdir "#{app_stats}/public"
  end
end

