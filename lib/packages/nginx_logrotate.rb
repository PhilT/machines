def stats_command(app)
  return unless AppConf.awstats

  command = File.join(AppConf.awstats.path, 'tools', 'awstats_buildstaticpages.pl')
  config = "-config=#{app.name}"
  dir = File.join(AppConf.awstats.stats_path, app.name) # TODO: Check path is created when generating stats for first time
  script = "-awstatsprog=/usr/local/awstats/wwwroot/cgi-bin/awstats.pl"

  <<-SCRIPT
  prerotate
    #{command} -update #{config} #{dir} #{script} > /dev/null
  endscript
  SCRIPT
end

task :logrotate_nginx, 'Logrotate nginx access and error logs and optionally generate stats' do
  nginx_erb = File.join(AppConf.project_dir, 'logrotate', 'nginx.erb')
  AppConf.apps.each do |app_name, app|
    %w(access error).each do |type|
      command = type == 'access' ? stats_command(app) : nil
      settings = AppSettings::AppBuilder.new(:log_path => "/var/log/nginx/#{app.name}.#{type}.log", :stats_command => command)
      sudo create_from nginx_erb, :settings => settings, :to => "/etc/logrotate.d/#{app.name}_nginx_#{type}_log"
    end
  end
end

task :logrotate_apps, 'Logrotate Rails app logs' do
  app_erb = File.join(AppConf.project_dir, 'logrotate', 'app.erb')
  AppConf.apps.each do |app_name, app|
    settings = AppSettings::AppBuilder.new(:log_path => File.join(app.path, 'shared', 'log', '*.log'))
    sudo create_from app_erb, :settings => settings, :to => File.join('/etc', 'logrotate.d', "#{app.name}_app_log")
  end
end

