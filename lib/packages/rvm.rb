task :rvm, 'Install RVM' do
  sudo install ['git-core', 'curl']
  installer = "bash -s #{AppConf.rvm.version} < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )"
  run installer, check_file('~/.rvm/bin/rvm')

  run "source .bashrc", "type rvm | head -1 | grep 'rvm is a function' #{echo_result}"
  run remove 'rvm-installer'
end

task :rvm_prompt_off, 'turn off trust prompting for new .rvmrc files' do
  run append 'export rvm_trust_rvmrcs_flag=1', :to => '.rvmrc'
end

task :ruby, "Install Ruby, make #{AppConf.ruby.version}@global the default and install Bundler" do
  run "rvm install #{AppConf.ruby.version}", "rvm #{AppConf.ruby.version} #{echo_result}"
  run "rvm #{AppConf.ruby.version}@global --default", "ruby -v | grep #{AppConf.ruby.version} #{echo_result}"
  run write "gem: --no-rdoc --no-ri", :to => '.gemrc', :name => '.gemrc'
  run gem 'bundler'
end

