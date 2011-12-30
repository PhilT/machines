task :rbenv, "Install ruby-build, rbenv, ruby #{AppConf.ruby.version} and Bundler" do
  sudo install ['git-core']
  run git_clone 'git://github.com/sstephenson/ruby-build.git'
  sudo 'cd ~/ruby-build && ./install.sh'

  run git_clone 'git://github.com/sstephenson/rbenv.git', :to => '~/.rbenv'
  run append 'export PATH="$HOME/.rbenv/bin:$PATH"', :to => '~/.bashrc'
  run append '[ -f ~/.bundler-exec.sh ] && source ~/.bundler-exec.sh', :to => '~/.bashrc'
  run append 'eval "$(rbenv init -)"', :to => '~/.bashrc'
  run 'source ~/.bashrc'

  run "rbenv install #{AppConf.ruby.full_version}"
  run 'rbenv rehash'
  run "rbenv global #{AppConf.ruby.full_version}", "ruby -v | grep #{AppConf.ruby.version} #{echo_result}"

  run write "gem: --no-rdoc --no-ri", :to => '.gemrc', :name => '.gemrc'
  run gem 'bundler'
  run 'wget -q https://github.com/gma/bundler-exec/raw/master/bundler-exec.sh > ~/.bundler-exec.sh'#, file_check('~/.bundler-exec.sh')
  run 'source ~/.bashrc', "type ruby | grep run-with-bundler #{echo_result}"
end

