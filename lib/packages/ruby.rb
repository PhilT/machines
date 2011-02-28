run "rvm install #{AppConf.ruby.version}", :as => username, :check => "rvm #{AppConf.ruby.version} #{pass_fail}"
run "rvm #{AppConf.ruby.version} --default", :as => username, :check => "ruby -v | grep #{AppConf.ruby.version} #{pass_fail}"
append "gem: --no-rdoc --no-ri", :to => '/etc/gemrc'

