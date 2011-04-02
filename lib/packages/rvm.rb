sudo install 'curl'
dir = "#{AppConf.user.home}/.rvm/src/rvm"
install AppConf.rvm.url, :to => dir
run "source #{AppConf.user.home}/.rvm/scripts/rvm"
#run "rvm reload", :as => username    #may not be needed

