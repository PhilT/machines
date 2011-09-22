require 'spec_helper'

describe 'Help' do
  subject { Help.new }
  describe 'actions' do
    it { subject.actions.should == ['htpasswd', 'new', 'check', 'dryrun', 'tasks', 'build', 'help', 'packages', 'override'] }
  end

  describe 'to_s' do
    it { subject.to_s.should == <<-HELP
machines ACTION
ACTION can be:
  htpasswd                 Asks for a username and password and generates basic auth in webserver/conf/htpasswd
  new <DIR>                Creates a directory called DIR and generates an example machines project in it
  check                    Checks Machinesfile for syntax issues
  dryrun                   Runs through Machinesfile logging all commands to log/output.log but does not acutally run them
  tasks                    Lists the available tasks after asking for machine and user
  build [OPTIONS]          Asks some questions then builds your chosen machine. Use OPTIONS to skip questions. Use task=TASK to build just that task
  help                     Provides more detailed help including OPTIONS for build
  packages                 lists the available packages
  override <PACKAGE>       copies the default package into project/packages so it can be edited/overidden
    HELP
    }
  end

  describe 'detailed' do
    it 'outputs detailed help' do
      Help.detailed.should =~ /machines build \[OPTIONS\]/
    end
  end
end

