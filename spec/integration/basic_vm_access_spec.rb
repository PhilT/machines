require 'spec_helper'

describe 'htpasswd' do
  it 'SSHs into VM and SUDOs to check no password required' do
    #Machinesfile
    AppConf.from_hash(:user => {})
    AppConf.user.name = 'user'
    AppConf.user.pass = 'password'
    AppConf.target_address = 'testvm'
    command = 'echo $USER'
    File.new 'local_file', 'w'

    response = ''

    #Try to mix in SCP with SSH so we don't need to open a second connection
    Net::SCP.start AppConf.target_address, AppConf.user.name, :password => AppConf.user.pass do |scp|
      ssh = scp.session
      scp.upload! 'local_file', '/tmp/remote_dest'
      response = ssh.exec!("echo #{AppConf.user.pass} | sudo -S sh -c '#{command}'")
      response << ssh.exec!(command)
    end

    response.should include 'root'
    response.should include 'user'
  end
end

