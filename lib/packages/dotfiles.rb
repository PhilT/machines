username = $conf.machine.user

task :dotfiles, "Upload users/#{username}/dotfiles and set some env vars" do
  Dir["users/#{username}/dotfiles/*"].each do |source|
    run upload source, ".#{File.basename(source)}" if File.exists?(source)
  end
  run chmod 600, '$HOME/.ssh/id_rsa' if File.exists?("users/#{username}/dotfiles/ssh/id_rsa")

  run mkdir '$HOME/.ssh'
  run chmod 700, '$HOME/.ssh'
  $conf.hosts.to_hash.each do |host, address|
    run "ssh-keyscan -H #{host} >> $HOME/.ssh/known_hosts"
  end if $conf.hosts

  if $conf.set_rails_env_for.nil? || $conf.set_rails_env_for.include?($conf.environment)
    run append "export RAILS_ENV=#{$conf.environment}", to: '.profile' 
  end
  run append "export CDPATH=#{$conf.appsroot}", to: '.profile'

  authorized_key_file = "users/#{username}/authorized_keys"
  if File.exists?(authorized_key_file)
    run upload authorized_key_file, '.ssh/authorized_keys'
    run chmod 600, '.ssh/authorized_keys'
  end
end

