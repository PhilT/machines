username = $conf.machine.user

task :dotfiles, "Upload files in users/#{username}/dotfiles, prepend a dot and substitute some bashrc vars" do
  Dir["users/#{username}/dotfiles/*"].each do |source|
    run upload source, ".#{File.basename(source)}" if File.exists?(source)
  end

  run append "export RAILS_ENV=#{$conf.environment}", :to => '.profile'
  run append "export CDPATH=#{$conf.appsroot}", :to => '.profile'
end

authorized_key_file = "users/#{username}/authorized_keys"
if File.exists?(authorized_key_file)
  task :keyfiles, 'Upload authorized_keys file' do
    run mkdir '.ssh'
    run chmod 700, '.ssh'
    run upload authorized_key_file, '.ssh/authorized_keys'
    run chmod 600, '.ssh/authorized_keys'
  end
end

