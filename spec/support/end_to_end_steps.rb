module EndToEndSteps
  def ensure_vm_exists_and_can_connect
    response = ''
    begin
      Net::SSH.start 'testvm', 'user', :password => 'password' do |ssh|
        response = ssh.exec!('echo $USER')
      end
    rescue
      puts "A VM is required to run this test. Make sure /etc/hosts has an entry"
      puts "for testvm and a user exists on it called 'user' with 'password'"
    end
    response.should include 'user'
  end

  def can_generate_template
    Machines::Base.new.start('generate', 'project')
    files = %w(certificates) +
      %w(config/apps.yml config/config.yml) +
      %w(mysql nginx packages users Machinesfile)

    files.each do |name|
      File.should exist File.join(AppConf.project_dir, name)
    end
  end

  def can_generate_htpasswds_for_staging
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
end

