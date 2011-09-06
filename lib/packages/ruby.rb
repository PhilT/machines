task :ruby, 'Install Ruby' do
  run "rvm install #{AppConf.ruby.version}", "rvm #{AppConf.ruby.version} #{echo_result}"
  run "rvm #{AppConf.ruby.version} --default", "ruby -v | grep #{AppConf.ruby.version} #{echo_result}"
  sudo write "gem: --no-rdoc --no-ri", :to => '/etc/gemrc', :name => 'gemrc'
end

