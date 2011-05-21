task 'Install RVM' do
  sudo install 'curl'
  dir = "#{AppConf.user.home}/.rvm/src/rvm"
  install AppConf.rvm.url, :to => dir
end

task 'turn off trust prompting for new .rvmrc files' do
  run "source #{AppConf.user.home}/.rvm/scripts/rvm"
  run append 'export rvm_trust_rvmrcs_flag=1', :to => '#{AppConf.user.home}/.rvmrc'
end

