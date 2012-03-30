task :awstats, 'Install AWStats' do
  sudo install 'awstats'
  sudo create_from 'awstats/awstats.conf.erb', :to => File.join($conf.awstats.path, 'conf', 'awstats.conf')
end

