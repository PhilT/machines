module DryrunSteps
  def does_a_dry_run
    $input.answers = %w(maindb pa55)
    machines = Machines::Base.new

    machines.execute ['dryrun']
    $output.should == <<-THIS
Project created at project/
1. maindb
2. backupdb
3. philworkstation
4. staging
5. production
Select machine to build:
THIS
  end
end

