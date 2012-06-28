task :rbenv, "Install ruby-build, rbenv, ruby #{$conf.ruby.version} and Bundler" do
  sudo install ['git-core', 'curl']
  run git_clone 'git://github.com/sstephenson/ruby-build.git'
  sudo 'cd ~/ruby-build && ./install.sh', check_file('/usr/local/bin/ruby-build')


  # Safely execute bundler generated shims for your projects
  # (https://twitter.com/#!/tpope/statuses/165631968996900865)
  #     cd your_project
  #     mkdir .bin/safe
  #     bundle --binstubs=.bin (or just bundle if you use the example bashrc)
  #
  run git_clone 'git://github.com/sstephenson/rbenv.git', :to => '~/.rbenv'
  #NOTE: This path will not be available to the session as Net::SSH uses a non-login shell
  path = 'PATH=.bin/safe/../../.bin:$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH'
  run append path, :to => '~/.profile'
  rbenv = '$HOME/.rbenv/bin/rbenv'

  run "#{rbenv} install #{$conf.ruby.full_version}", check_command("#{rbenv} versions", $conf.ruby.version)
  run "#{rbenv} rehash", check_command("#{path} which gem", '.rbenv/shims/gem')
  run "#{rbenv} global #{$conf.ruby.full_version}", check_command("#{rbenv} exec ruby -v", $conf.ruby.version)

  run write "gem: --no-rdoc --no-ri", :to => '.gemrc', :name => '.gemrc'
  run "#{rbenv} exec gem install bundler", check_command("#{rbenv} exec gem list", 'bundler')
  run "#{rbenv} rehash", check_command("#{path} which bundle", '.rbenv/shims/bundle')
end

