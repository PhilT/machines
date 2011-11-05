task :ruby, "Install Ruby, make #{AppConf.ruby.version}@global the default and install Bundler" do
  run "rvm install #{AppConf.ruby.version}", "rvm #{AppConf.ruby.version} #{echo_result}"
  run "rvm #{AppConf.ruby.version}@global --default", "ruby -v | grep #{AppConf.ruby.version} #{echo_result}"
  run write "gem: --no-rdoc --no-ri", :to => '.gemrc', :name => '.gemrc'
  run gem 'bundler'
end

