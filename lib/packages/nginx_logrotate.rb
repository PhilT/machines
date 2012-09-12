task :logrotate_nginx, 'Logrotate nginx access and error logs and optionally generate stats' do
  $conf.webapps.each do |app_name, app|
    %w(access error).each do |type|
      if type == 'access' && app.stats
        stats_prerotate = "/usr/lib/cgi-bin/awstats.pl -update -config=#{app.server_name} > /dev/null"
        stats_postrotate = "/usr/local/bin/awstats_render #{app.server_name} #{app.path}_stats/public > /dev/null"
      else
        stats_prerotate = stats_postrotate = nil
      end
      settings = AppBuilder.new(
        log_path: "/var/log/nginx/#{app.name}.#{type}.log",
        stats_prerotate: stats_prerotate,
        stats_postrotate: stats_postrotate
      )
      sudo create_from 'logrotate/nginx.erb', settings: settings, to: "/etc/logrotate.d/#{app.name}_nginx_#{type}"
    end
  end
end

task :logrotate_apps, 'Logrotate Rails app logs' do
  $conf.webapps.each do |app_name, app|
    settings = AppBuilder.new(log_path: File.join(app.path, 'shared', 'log', '*.log'))
    sudo create_from 'logrotate/app.erb', settings: settings, to: File.join('/etc', 'logrotate.d', "#{app.name}_app")
  end
end

