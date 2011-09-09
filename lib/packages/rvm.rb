task :rvm, 'Install RVM' do
  sudo install ['git-core', 'curl']
  installer = "curl -s #{AppConf.rvm.url} -o rvm-installer ; chmod +x rvm-installer ; ./rvm-installer --version #{AppConf.rvm.version}"
  run installer, check_file('~/.rvm/bin/rvm')
  run append '[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # Load RVM function', :to => '.bashrc'
  run "source .bashrc", "type rvm | head -1 | grep 'rvm is a function' #{echo_result}"
end

task :rvm_prompt_off, 'turn off trust prompting for new .rvmrc files' do
  run append 'export rvm_trust_rvmrcs_flag=1', :to => '.rvmrc'
end

