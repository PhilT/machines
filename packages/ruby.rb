run "rvm install #{Config.ruby.version}", :as => username, :check => "rvm #{Config.ruby.version} #{pass_fail}"
run "rvm #{Config.ruby.version} --default", :as => username, :check => "ruby -v | grep #{Config.ruby.version} #{pass_fail}"
append "gem: --no-rdoc --no-ri", :to => '/etc/gemrc'

