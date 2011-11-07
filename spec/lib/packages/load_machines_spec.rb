require 'spec_helper'

describe 'packages/load_machines' do
  before(:each) do
    load_package('load_machines')
    settings = <<-EOF
      a_machine:
        hostname: something
        environment: development
    EOF
    File.open('machines.yml', 'w') {|f| f.puts settings }
    eval_package
  end

  it 'loads the machines.yml file' do
    AppConf.machines.should == {'a_machine' => {'hostname' => 'something', 'environment' => 'development'}}
  end
end

