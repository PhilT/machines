install %w(curl)
dir = "#{AppConf.user.home}/.rvm/src/rvm"

install AppConf.rvm.url, :to => dir, :as => AppConf.user.name
run "source #{AppConf.user.home}/.rvm/scripts/rvm", :as => AppConf.user.name
#run "rvm reload", :as => username    #may not be needed

