require 'spec_helper'

describe 'Functional Specs' do
  before(:each) do
    @machines = Machines::Base.new(:machine => 'machine', :host => 'localhost', :keyfile => 'keyfile')
    @machines.stub!(:puts)
  end

  it 'should test a minimal script' do
    pending
    @machines.stub!(:development?).and_return(true)
    File.stub!(:exist?).and_return(true)
    @machines.should_receive(:log_to).with(:screen, "3:     echo 'machine' > /etc/hostname")
    @machines.should_receive(:log_to).with(:screen, "check: grep 'machine' /etc/hostname && echo CHECK PASSED || echo CHECK FAILED")
    @machines.should_receive(:log_to).with(:screen, "3:     etc/hosts to /etc/hosts")
    @machines.should_receive(:log_to).with(:screen, "check: test -s /etc/hosts && echo CHECK PASSED || echo CHECK FAILED")
    @machines.should_receive(:log_to).with(:screen, "3:     export TERM=linux && hostname machine")
    @machines.should_receive(:log_to).with(:screen, "no check")
    @machines.should_receive(:log_to).with(:screen, "4:     useradd -s /bin/bash -d /home/www -m -G admin www")
    @machines.should_receive(:log_to).with(:screen, "check: test -d /home/www && echo CHECK PASSED || echo CHECK FAILED")
    @machines.should_receive(:log_to).with(:screen, "5:     echo 'www ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers")
    @machines.should_receive(:log_to).with(:screen, "check: grep 'www ALL=(ALL) NOPASSWD: ALL' /etc/sudoers && echo CHECK PASSED || echo CHECK FAILED")
    @machines.dryrun
  end

  #Setup SSH to hit a VM. Make this an optional spec
  it 'should setup a minimal script' do
    pending
    @machines.setup
  end
end

