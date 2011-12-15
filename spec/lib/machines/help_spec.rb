require 'spec_helper'

describe 'Help' do
  subject { Help.new }
  describe 'actions' do
    it { subject.actions.should == ['htpasswd', 'new', 'dryrun', 'tasks', 'build', 'packages', 'override'] }
  end

  describe 'to_s' do
    it { subject.to_s.should == <<-HELP
machines ACTION
ACTION can be:
  htpasswd                 Generates basic auth in webserver/conf/htpasswd
  new <DIR>                Generates an example machines project in DIR
  dryrun                   Logs commands but does not run them
  tasks                    Lists the available tasks
  build <machine> [task]   Builds your chosen machine. Optionally, build just one task
  packages                 Lists the available packages
  override <PACKAGE>       Copies the default package into project/packages so it can be edited/overidden
    HELP
    }
  end
end

