username = $conf.machine.user

task :dotfiles, "Upload files in users/#{username}/dotfiles, prepend a dot and substitute some bashrc vars" do
  Dir["users/#{username}/dotfiles/*"].each do |source|
    run upload source, ".#{File.basename(source)}" if File.exists?(source)
  end
  run chmod 600, '$HOME/.ssh/id_rsa' if File.exists?("users/#{username}/dotfiles/ssh/id_rsa")

  run mkdir '$HOME/.ssh'
  run chmod 700, '$HOME/.ssh'
  $conf.hosts.to_hash.each do |host, address|
    run "ssh-keyscan -H #{host} >> $HOME/.ssh/known_hosts"
  end if $conf.hosts

  run append "export RAILS_ENV=#{$conf.environment}", :to => '.profile'
  run append "export CDPATH=#{$conf.appsroot}", :to => '.profile'

  authorized_key_file = "users/#{username}/authorized_keys"
  if File.exists?(authorized_key_file)
    run upload authorized_key_file, '$HOME/.ssh/authorized_keys'
    run chmod 600, '$HOME/.ssh/authorized_keys'
  end
end

