task 'Install RVM' do
  sudo install 'curl'
  run "bash < <(curl -s https://rvm.beginrescueend.com/install/rvm)"
  run append '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function', :to => File.join(AppConf.user.home, '.bashrc')
end

task 'turn off trust prompting for new .rvmrc files' do
  run append 'export rvm_trust_rvmrcs_flag=1', :to => "#{AppConf.user.home}/.rvmrc"
end

run "source #{AppConf.user.home}/.bashrc", "type rvm | head -1 | grep 'rvm is a function' #{echo_result}"

