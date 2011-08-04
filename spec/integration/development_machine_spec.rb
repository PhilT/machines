require 'integration_helper'
require 'integration/development_machine_steps'

describe 'Development Machine Build' do
  include DevelopmentMachineSteps

  before(:each) do
    start_vm
    ensure_vm_exists_and_can_connect
  end

  after(:each) do
    stop_vm
  end

  it 'does a dry run then real build' do
    generates_template
    runs_build
  end
end

