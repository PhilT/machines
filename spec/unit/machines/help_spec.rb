require 'spec_helper'

describe 'Help' do
  subject { Help.new }
  describe 'commands' do
    it { subject.commands.should == ['htpasswd', 'new', 'check', 'dryrun', 'build', 'packages', 'override'] }
  end

  describe 'to_s' do
    it { subject.to_s.should == <<-HELP
machines COMMAND
COMMAND can be:
  htpasswd                 Asks for a username and password and generates basic auth in webserver/conf/htpasswd
  new <DIR>                Creates a directory called DIR and generates an example machines project in it
  check                    Checks Machinesfile for syntax issues
  dryrun                   Runs through Machinesfile logging all commands to log/output.log but does not acutally run them
  build [TASK]             Asks some questions then builds your chosen machine. If TASK is specified just builds that
  packages                 lists the available packages
  override <PACKAGE>       copies the default package into project/packages so it can be edited/overidden
    HELP
    }
  end
end

