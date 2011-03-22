require 'spec_helper'

describe 'htpasswd' do
  it 'generates a crypt password and appends it to htpasswd in nginx folder' do
    AppConf.webserver = 'nginx'
    machines = Machines::Base.new
    machines.should_receive(:say).with /Generate BasicAuth password and add to .*tmp\/integration\/nginx\/conf\/htpasswd/
    machines.should_receive(:ask).with('Username: ').and_return 'user'
    machines.should_receive(:enter_password).and_return 'pass'
    machines.should_receive(:say).with /Password encrypted and added to .*tmp\/integration\/nginx\/conf\/htpasswd/
    machines.start('htpasswd')
    File.read('tmp/integration/nginx/conf/htpasswd').should =~ /user:.{13}/
  end

  it 'make sure password is appended to existing htpasswd file' do
    pending
  end
end

