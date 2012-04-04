task :rbenv, "Install ruby-build, rbenv, ruby #{$conf.ruby.version} and Bundler" do
  sudo install ['git-core', 'curl']
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
  #NOTE: This path will not be available to the session as Net::SSH uses a non-login shell
  run append 'PATH=".git/safe/../../.bin:$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"', :to => '~/.profile'

  run "~/.rbenv/bin/rbenv install #{$conf.ruby.full_version}"
  run '~/.rbenv/bin/rbenv rehash'
  run "~/.rbenv/bin/rbenv global #{$conf.ruby.full_version}", "~/.rbenv/bin/rbenv exec ruby -v | grep #{$conf.ruby.version} #{echo_result}"

  run write "gem: --no-rdoc --no-ri", :to => '.gemrc', :name => '.gemrc'
  run '~/.rbenv/bin/rbenv exec gem install bundler', "~/.rbenv/bin/rbenv exec gem list | grep bundler #{echo_result}"
end

