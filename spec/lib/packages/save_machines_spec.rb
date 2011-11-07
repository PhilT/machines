require 'spec_helper'

describe 'packages/save_machines' do
  before(:each) do
    load_package('save_machines')
    AppConf.machines = {'a_machine' => {'hostname' => 'something', 'environment' => 'development'}}
  end

  it 'loads the machines.yml file' do
    File.open('machines.yml', 'w'){|f| f.puts "\n"}
    eval_package
    File.read('machines.yml').should == <<-EOF


---
a_machine:
  hostname: something
  environment: development
    EOF
  end

  it 'preserves comments' do
    File.open('machines.yml', 'w'){|f| f.puts "# Some comments\n\na_machine:\n  hostname:\n"}
    eval_package
    File.read('machines.yml').should == <<-EOF
# Some comments

---
a_machine:
  hostname: something
  environment: development
    EOF
  end

  it 'raises when no machines.yml' do
    lambda { eval_package }.should raise_error Errno::ENOENT
  end
end

