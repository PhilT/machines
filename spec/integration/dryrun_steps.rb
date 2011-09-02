module DryrunSteps
  def does_a_dry_run
    $input.answers = %w(Desktop phil pa$$ pa$$ host)
    machines = Machines::Base.new

    machines.execute('dryrun', nil)
    $output.should == <<-THIS
Project created at /home/phil/workspace/machines/tmp/project
1. Desktop
2. Staging
3. Production
4. DBmaster
5. DBslave
Select machine to build:
1. phil
2. www-data
Select a user:
Enter users password:
Hostname to set machine to (Shown on bash prompt if default .bashrc used):
THIS
  end
end

