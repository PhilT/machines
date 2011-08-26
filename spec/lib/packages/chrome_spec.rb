require 'spec_helper'

describe 'packages/chrome' do
  before(:each) do
    load_package('chrome')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   chrome - Add chrome stable repo and install",
      "SUDO   echo deb http://dl.google.com/linux/deb/ stable main >> /etc/apt/sources.list",
      "SUDO   wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O - | apt-key add -",
      "SUDO   export DEBIAN_FRONTEND=noninteractive && apt-get -q -y update",
      "SUDO   apt-get -q -y install google-chrome-stable"
    ]
  end
end

