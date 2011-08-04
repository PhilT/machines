require 'integration_helper'
require 'integration/dryrun_steps'

describe 'dryrun' do
  include DryrunSteps

  it 'does a dry run' do
    generates_template
    does_a_dry_run
  end
end

