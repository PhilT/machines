require 'spec_helper'

describe 'htpasswd' do
  it 'SSHs into VM and SUDOs to check no password required' do
    #Machinesfile
    AppConf.from_hash(:user => {})
    AppConf.user.name = 'user'
    AppConf.user.pass = 'password'
    AppConf.target_address = 'testvm'
    command = 'echo $USER'

    response = ''
    Net::SSH.start AppConf.target_address, AppConf.user.name, :password => AppConf.user.pass do |ssh|
      response = ssh.exec!("echo #{AppConf.user.pass} | sudo -S sh -c '#{command}'")
      response << ssh.exec!(command)
    end
    response.should include 'root'
    response.should include 'user'
  end
end

