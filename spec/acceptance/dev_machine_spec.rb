require 'minitest/autorun'
require './spec/support/vm_control'

describe 'Development machine' do
  before do
    if File.exist?('.vmconfig')
      @vm_control = File.read('.vmconfig') =~ /^HOST=WINDOWS/ ? WinVmControl.new : VmControl.new
    else
      flunk '.vmconfig does not exist. Touch it to test using VMs on a Linux host or add HOST=WINDOWS to test on a VM running on Windows.'
    end
  end

  after do
    @vm_control.kill
  end

  it 'does a dryrun then build' do
    if !@vm_control.restore
      flunk 'Connection timed out. Did you start your SSH server on the host?'
    end
    flunk unless @vm_control.start
    response = ''
    connection_error = nil
    10.times do
      begin
        Net::SSH.start 'machinesvm', 'user', :password => 'password' do |ssh|
          connection_error = nil
          response = ssh.exec!('echo $USER')
        end
        break
      rescue => e
        connection_error = e
        puts e
        sleep 3
      end
    end
    response.must_match /user/


#    `cd tmp && rm -rf acceptance_project && machines new acceptance_project && cd acceptance_project && machines philworkstation dryrun`

#    `cd tmp/acceptance_project && machines philworkstation build`


  end
end

