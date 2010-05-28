require 'spec_helper'

describe 'Functional Specs' do
  before(:each) do
    @machines = Machines::Base.new(:machine => 'machine', :host => 'localhost', :keyfile => 'keyfile')
    @machines.stub!(:puts)
  end

  it 'should test a minimal script' do
    @machines.stub!(:development?).and_return(true)
    File.stub!(:exist?).and_return(true)
    @machines.should_receive(:log_to).with(:screen, ")    sed -i 's/ubuntu/machine/' /etc/{hosts,hostname}")
    @machines.should_receive(:log_to).with(:screen, ")    hostname machine")
    @machines.should_receive(:log_to).with(:screen, ")    useradd -s /bin/bash -d /home/www -m -p password -G admin www")
    @machines.should_receive(:log_to).with(:screen, ")    echo 'www ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers")
    @machines.dryrun
  end

  #Setup SSH to hit a VM. Make this an optional spec
  it 'should install a minimal script' do
    pending
    @machines.install
  end
end

