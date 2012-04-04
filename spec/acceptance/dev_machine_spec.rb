require 'minitest/autorun'
class VmControl < MiniTest::Spec; end
require './spec/support/vm_control'
require 'app_conf'


describe 'Development machine' do
  def run_in_shell command
    output = `#{command}`
    flunk output unless $?.success?
  end

  before do
    @vm = VmControl.new
    run_in_shell 'cd tmp && rm -rf acceptance_project'
  end

  after do
    @vm.kill
  end

  it 'does a dryrun then build' do
    run_in_shell 'cd tmp && ruby -I../lib ../bin/machines new acceptance_project'
    files = %w(certificates webapps.yml config.yml mysql nginx packages users Machinesfile)
    files.each do |name|
      File.exist?(File.join('tmp', 'acceptance_project', name)).must_equal true
    end

    appConf = AppConf.new
    appConf.load('tmp/acceptance_project/machines.yml')
    appConf.machines.philworkstation.address = 'machinesvm'
    appConf.save(:machines, 'tmp/acceptance_project/machines.yml')

    run_in_shell 'cd tmp/acceptance_project && ruby -I../../lib ../../bin/machines dryrun philworkstation'

    @vm.restore
    @vm.start
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
        sleep 3
      end
    end
    response.must_match /user/

    # Need to specify passwords
    #run_in_shell 'cd tmp/acceptance_project && ruby -I../../lib ../../bin/machines build philworkstation'
  end
end

