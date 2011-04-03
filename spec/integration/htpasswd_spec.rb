require 'spec_helper'

describe 'htpasswd' do
  before(:each) do
    @input = MockStdIn.new
    @output = MockStdOut.new
    $terminal = HighLine.new(@input, @output)
  end

  it 'generates a crypt password and appends it to htpasswd in nginx folder' do
    @input.answers = ['user', 'pass', 'p1ass', 'pass']

    AppConf.webserver = 'nginx'
    machines = Machines::Base.new

    machines.start('htpasswd')
    response = @output.buffer
    response.should include "Generate BasicAuth password and add to #{AppConf.project_dir}/nginx/conf/htpasswd"
    response.should include "Username:"
    response.should include "Enter a new password:"
    response.should include "Confirm the password:"
    response.should include "Passwords do not match, please re-enter"
    response.should include "Enter a new password:"
    response.should include "Password encrypted and added to #{AppConf.project_dir}/nginx/conf/htpasswd"
    File.read("#{AppConf.project_dir}/nginx/conf/htpasswd").should =~ /user:.{13}/
  end

  it 'make sure password is appended to existing htpasswd file' do
    pending
  end
end

