require 'spec_helper'

describe 'Functional Specs' do
  before(:each) do
    stub!(:print)
  end

  it 'should test a minimal script' do

    machines = Machines::Base.new(:machine => 'machine', :userpass => 'password')
    machines.should_receive(:log_to).with(:screen, ")    sed -i 's/ubuntu/machine/' /etc/{hosts,hostname}")
    machines.should_receive(:log_to).with(:screen, ")    hostname machine")
    machines.should_receive(:log_to).with(:screen, ")    useradd -s /bin/bash -d /home/www -m -p password -G admin www")
    machines.should_receive(:log_to).with(:screen, ")    echo 'www ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers")
    machines.dryrun

#    machines.log.should == [')    etc/hosts to /etc/hosts']
#    machines.commands.should == [['', ["etc/hosts", "/etc/hosts"], 'test -s /etc/hosts && echo CHECK PASSED || echo CHECK FAILED']]
  end

  it 'should install a minimal script' do
    pending
  end
end

