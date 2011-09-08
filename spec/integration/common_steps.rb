module CommonSteps
  def start_vm
    puts $terminal.color("Restoring snapshot", :blue)
    system('VBoxManage snapshot machinesvm restore Clean')

    puts $terminal.color("Starting VM", :blue)
    system('VBoxManage startvm machinesvm --type headless')
  end

  def stop_vm
    return unless `VBoxManage showvminfo machinesvm | grep State` =~ /running/
    puts $terminal.color("Stopping VM", :blue)
    system('VBoxManage controlvm machinesvm poweroff')
    sleep 3
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
        sleep 3
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
    Machines::Base.new.execute('new', 'project')
    FileUtils.cd 'project'
    files = %w(certificates) +
      %w(config/apps.yml config/config.yml) +
      %w(mysql nginx packages users Machinesfile)

    files.each do |name|
      File.should exist name
    end
  end
end

