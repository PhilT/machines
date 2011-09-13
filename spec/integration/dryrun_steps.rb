module DryrunSteps
  def does_a_dry_run
    $input.answers = %w(Desktop phil pa$$ pa$$ host)
    machines = Machines::Base.new

    machines.execute('dryrun', nil)
    $output.should == <<-THIS
Project created at project/
1. Desktop
2. Laptop
3. Staging
4. Production
5. DBmaster
6. DBslave
Select machine to build:
1. phil
2. www-data
Select a user:
THIS
  end
end

