module EndToEndSteps
  def start_vm
    system('VBoxManage startvm machinesvm --type headless')
  end

  def stop_vm
    system('VBoxManage controlvm machinesvm poweroff')
  end

  def ensure_vm_exists_and_can_connect
    response = ''
    connection_error = nil
    puts 'Attempting to connect to VM...'
    10.times do
      begin
        Net::SSH.start 'machinesvm', 'user', :password => 'password' do |ssh|
          connection_error = nil
          puts $terminal.color('Connected.', :green)
          response = ssh.exec!('echo $USER')
        end
        break
      rescue => e
        connection_error = e
        sleep 5
      end
    end
    if connection_error
      puts $terminal.color("A VM is required to run this test. Make sure /etc/hosts has an entry", :bold, :red)
      puts $terminal.color("for machinesvm and a user exists on it called 'user' with 'password'", :bold, :red)
      puts $terminal.color("Error: #{connection_error.message}", :red)
    end
    response.should include 'user'
  end

  def generates_template
    Machines::Base.new.start('new', 'project')
    files = %w(certificates) +
      %w(config/apps.yml config/config.yml) +
      %w(mysql nginx packages users Machinesfile)

    files.each do |name|
      File.should exist File.join(AppConf.project_dir, name)
    end
  end

  def generates_htpasswd_to_limit_access_to_staging
    $input.answers = ['user', 'pass', 'p1ass', 'pass', 'pass']

    AppConf.webserver = 'nginx'
    machines = Machines::Base.new

    machines.start('htpasswd', nil)
    $output.should == <<-THIS
Generate BasicAuth password and add to nginx/conf/htpasswd
Username:
Enter a new password:
Confirm the password:
Passwords do not match, please re-enter
Enter a new password:
Confirm the password:
Password encrypted and added to nginx/conf/htpasswd
THIS
    File.read("#{AppConf.project_dir}/nginx/conf/htpasswd").should =~ /user:.{13}/
  end

  def checks_machinesfile

  end
end

