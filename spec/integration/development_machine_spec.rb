require 'integration_helper'
require 'integration/development_machine_steps'

describe 'Development Machine Build' do
  include DevelopmentMachineSteps

  it 'generates template, asks questions and runs build script' do
    generates_template
    checks_machinesfile
  end
end

