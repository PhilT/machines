task :ssh_keygen, 'Generate SSH key and present it' do
  if $conf.machine.use_local_ssh_id || $conf.log_only
    $conf.id_rsa = File.read(File.join(ENV['HOME'], '.ssh/id_rsa'))
  else
    begin
      system %(ssh-keygen -q -f tmp/#{$conf.machine_name}_id_rsa -N "")
      sshkey_path = "tmp/#{$conf.machine_name}_id_rsa"
      $conf.id_rsa = File.read(sshkey_path)
      say 'Copy the following key and add it to GitHub (and another other services that require it):'
      say File.read(sshkey_path + '.pub')
    ensure
      system 'rm -f tmp/*id_rsa*'
    end

    exit unless agree('Ready to continue? ("y", or "n" to abort)')
  end
end
