task :rbenv, "Install ruby-build, rbenv, ruby #{$conf.ruby.version} and Bundler" do
  sudo install ['git-core']
  run git_clone 'git://github.com/sstephenson/ruby-build.git'
  sudo 'cd ~/ruby-build && ./install.sh'


  # Safely execute bundler generated shims for your projects
  # (https://twitter.com/#!/tpope/statuses/165631968996900865)
  #
  #     cd your_project
  #     mkdir .git/safe
  #     bundle --binstubs=.bin (or just bundle if you use the example bashrc)
  #
  run git_clone 'git://github.com/sstephenson/rbenv.git', :to => '~/.rbenv'
  run append 'export PATH=".git/safe/../../.bin:$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"', :to => '~/.profile'

  # DOES THIS WORK? (E.G. SOURCING PROFILE to get the exported path)
  run 'source ~/.profile'

  run "rbenv install #{$conf.ruby.full_version}"
  run 'rbenv rehash'
  run "rbenv global #{$conf.ruby.full_version}", "ruby -v | grep #{$conf.ruby.version} #{echo_result}"

  run write "gem: --no-rdoc --no-ri", :to => '.gemrc', :name => '.gemrc'
  run gem 'bundler'
  run 'wget -q https://github.com/gma/bundler-exec/raw/master/bundler-exec.sh > ~/.bundler-exec.sh'#, file_check('~/.bundler-exec.sh')
  run 'source ~/.bashrc', "type ruby | grep run-with-bundler #{echo_result}"
end

