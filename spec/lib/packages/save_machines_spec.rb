require 'spec_helper'

describe 'packages/save_machines' do
  before(:each) do
    load_package('save_machines')
    AppConf.machines = {'a_machine' => {'hostname' => 'something', 'environment' => 'development'}}
    eval_package
  end

  it 'loads the machines.yml file' do
    File.read('machines.yml').should == <<-EOF
---
a_machine:
  hostname: something
  environment: development
    EOF
  end
end

