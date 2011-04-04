# Install RVM and turn off trust prompting for new .rvmrc files

sudo install 'curl'
dir = "#{AppConf.user.home}/.rvm/src/rvm"
install AppConf.rvm.url, :to => dir
run "source #{AppConf.user.home}/.rvm/scripts/rvm"
run append 'export rvm_trust_rvmrcs_flag=1', :to => '#{AppConf.user.home}/.rvmrc'

