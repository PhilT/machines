module DryrunSteps
  def does_a_dry_run
    machines = Machines::Base.new
    machines.execute ['philworkstation', 'dryrun']
  end
end

