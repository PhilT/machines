require 'spec_helper'

describe 'packages/save_machines' do
  before(:each) do
    load_package('save_machines')
    AppConf.machines_changed = true
    AppConf.from_hash({'machines' => {'a_machine' => {'hostname' => 'something', 'environment' => 'development'}}})
  end

  it 'loads the machines.yml file' do
    File.open('machines.yml', 'w'){|f| f.puts "\n"}
    eval_package
    File.read('machines.yml').should == <<-EOF
---
machines:
  a_machine:
    hostname: something
    environment: development
    EOF
  end

  it 'preserves comments' do
    File.open('machines.yml', 'w'){|f| f.puts "# Some\n# comments\n---\na_machine:\n  hostname:\n"}
    eval_package
    File.read('machines.yml').should == <<-EOF
# Some
# comments
---
machines:
  a_machine:
    hostname: something
    environment: development
    EOF
  end

  it 'does not raise when no machines.yml' do
    lambda { eval_package }.should_not raise_error Errno::ENOENT
  end

  it 'only saves when something changed' do
    AppConf.should_receive :save
    eval_package
  end

  it 'does not save when nothing changed' do
    AppConf.clear :machines_changed
    AppConf.should_not_receive :save
    eval_package
  end
end
