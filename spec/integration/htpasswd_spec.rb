require 'spec_helper'

describe 'htpasswd' do
  before(:each) do
    FileUtils.rm_rf 'tmp/project'
    FileUtils.mkdir_p 'tmp/project'
    FileUtils.chdir 'tmp/project'
  end

  after(:each) do
    FileUtils.chdir '../..'
  end

  it 'generates a crypt password and appends it to htpasswd in nginx folder' do
    AppConf.webserver = 'nginx'
    machines = Machines::Base.new
    machines.should_receive(:say).with 'Generate BasicAuth password and add to nginx/conf/htpasswd'
    machines.should_receive(:ask).with('Username: ').and_return 'user'
    machines.should_receive(:enter_password).and_return 'pass'
    machines.should_receive(:say).with "Password encrypted and added to nginx/conf/htpasswd"
    machines.start('htpasswd')
    File.read('nginx/conf/htpasswd').should =~ /user:.{13}/
  end

  it 'make sure password is appended to existing htpasswd file' do
    pending
  end
end

