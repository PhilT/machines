module StagingMachineSteps
  def generates_htpasswd
    $input.answers = %w(user pas p1ass pass pass)

    AppConf.webserver = 'nginx'
    machines = Machines::Base.new

    machines.execute ['htpasswd']
    $output.should == <<-THIS
Project created at project/
Generate BasicAuth password and add to nginx/conf/htpasswd
Username:
Enter users password:
Confirm the password:
Passwords do not match, please re-enter
Enter users password:
Confirm the password:
Password encrypted and added to nginx/conf/htpasswd
THIS
    File.read("nginx/conf/htpasswd").should =~ /user:.{13}/
  end
end

