def stats_command(app)
  return unless AppConf.awstats

  dir = File.join(AppConf.awstats.stats_path, app.name) # TODO: Check path is created when generating stats for first time

  <<-SCRIPT
  sharedscripts
  prerotate
    /usr/lib/cgi-bin/awstats.pl -update -config=#{app.name} #{dir} > /dev/null
  endscript
  SCRIPT
end

task :logrotate_nginx, 'Logrotate nginx access and error logs and optionally generate stats' do
  AppConf.apps.each do |app_name, app|
    %w(access error).each do |type|
      command = type == 'access' ? stats_command(app) : nil
      settings = AppSettings::AppBuilder.new(:log_path => "/var/log/nginx/#{app.name}.#{type}.log", :stats_command => command)
      sudo create_from 'logrotate/nginx.erb', :settings => settings, :to => "/etc/logrotate.d/#{app.name}_nginx_#{type}_log"
    end
  end
end

task :logrotate_apps, 'Logrotate Rails app logs' do
  AppConf.apps.each do |app_name, app|
    settings = AppSettings::AppBuilder.new(:log_path => File.join(app.path, 'shared', 'log', '*.log'))
    sudo create_from 'logrotate/app.erb', :settings => settings, :to => File.join('/etc', 'logrotate.d', "#{app.name}_app_log")
  end
end

