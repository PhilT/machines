task :cruisecontrol, 'Install, configure and set to start on boot' do
  git_clone 'https://github.com/thoughtworks/cruisecontrol.rb.git'
  #HACK: PATHS are added to .profile which is not run on a non-login shell. NET::Ssh creates non-login shells
  if $conf.ruby.gems_path =~ /^.rbenv/
    bin = '~/.rbenv/bin/rbenv exec'
  else
    bin = ''
  end

  run "cd cruisecontrol.rb && #{bin} bundle"
  $conf.webapps.each do |name, webapp|
    run "cd cruisecontrol.rb && #{bin} ruby ./cruise add #{webapp.title} -r #{webapp.scm}"
  end

  sudo copy 'cruisecontrol.rb/daemon/cruise', '/etc/init.d/cruise'
  sudo "update-rc.d cruise defaults"
  sudo append "export CRUISE_HOME=#{$conf.user_home}/cruisecontrol.rb", :to => '/etc/profile'
end

