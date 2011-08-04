module StagingMachineSteps
  def generates_htpasswd
    $input.answers = %w(user pass p1ass pass pass)

    AppConf.webserver = 'nginx'
    machines = Machines::Base.new

    machines.start('htpasswd', nil)
    $output.should == <<-THIS
Project created at /home/phil/workspace/machines/tmp/project
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

