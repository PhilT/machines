task :rvm, 'Install RVM' do
  full_version = "#{$conf.ruby.version}-#{$conf.ruby.build}"
  $conf.ruby.gems_path = ".rvm/gems/#{full_version}/@global/gems"
  $conf.ruby.executable = ".rvm/wrappers/#{full_version}@global/ruby"

  sudo install ['git-core']
  installer = "bash -s #{$conf.rvm.version} < <(wget -q https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )"
  run installer, check_file('~/.rvm/bin/rvm')

  run "source .bashrc", "type rvm | head -1 | grep 'rvm is a function' #{echo_result}"
  run remove 'rvm-installer'
end

task :rvm_prompt_off, 'turn off trust prompting for new .rvmrc files' do
  run append 'export rvm_trust_rvmrcs_flag=1', :to => '.rvmrc'
end

task :ruby, "Install Ruby, make #{$conf.ruby.version}-#{$conf.ruby.build}@global the default and install Bundler" do
  run "rvm install #{$conf.ruby.version}", "rvm #{$conf.ruby.version} #{echo_result}"
  run "rvm #{$conf.ruby.version}@global --default", "ruby -v | grep #{$conf.ruby.version} #{echo_result}"
  run write "gem: --no-rdoc --no-ri", :to => '.gemrc', :name => '.gemrc'
  run gem 'bundler'
end

