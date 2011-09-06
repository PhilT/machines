task :rvm, 'Install RVM' do
  sudo install ['git-core', 'curl']
  installer = 'curl -s https://rvm.beginrescueend.com/install/rvm -o rvm-installer ; chmod +x rvm-installer ; ./rvm-installer --version 1.8.0'
  run installer, check_file('~/.rvm/bin/rvm')
  run append '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function', :to => File.join(AppConf.user.home, '.bashrc')
  run "source #{AppConf.user.home}/.bashrc", "type rvm | head -1 | grep 'rvm is a function' #{echo_result}"
end

task :rvm_prompt_off, 'turn off trust prompting for new .rvmrc files' do
  run append 'export rvm_trust_rvmrcs_flag=1', :to => "#{AppConf.user.home}/.rvmrc"
end

