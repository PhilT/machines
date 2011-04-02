run "rvm install #{AppConf.ruby.version}", :as => username, :check => "rvm #{AppConf.ruby.version} #{echo_result}"
run "rvm #{AppConf.ruby.version} --default", :as => username, :check => "ruby -v | grep #{AppConf.ruby.version} #{echo_result}"
sudo append "gem: --no-rdoc --no-ri", :to => '/etc/gemrc'

