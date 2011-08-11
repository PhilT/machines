task :awstats, 'Download and install AWStats' do
  sudo extract AppConf.awstats.url, :to => AppConf.awstats.path
  awstats_erb = File.join(AppConf.project_dir, 'awstats', 'awstats.conf.erb')
  sudo create_from awstats_erb, :to => File.join(AppConf.awstats.path, 'conf', 'awstats.conf')
end

