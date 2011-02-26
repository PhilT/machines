install %w(curl)
dir = "#{@homepath}/.rvm/src/rvm"

install Config.rvm.url, :to => dir, :as => username
run "source #{@homepath}/.rvm/scripts/rvm", :as => username
#run "rvm reload", :as => username    #may not be needed

