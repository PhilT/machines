require 'integration_helper'
require 'integration/staging_machine_steps'

describe 'Staging Machine Build' do
  include StagingMachineSteps

  it 'generates template and htpasswd file and runs build', :vm => true do
    generates_template
    generates_htpasswd
  end
end

