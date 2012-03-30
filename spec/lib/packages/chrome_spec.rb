require 'spec_helper'

describe 'packages/chrome' do
  before(:each) do
    load_package('chrome')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   chrome - Add chrome stable repo and install",
      "SUDO   echo deb http://dl.google.com/linux/deb/ stable main >> /etc/apt/sources.list",
      "SUDO   wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O - | apt-key add -",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install google-chrome-stable"
    ]
  end
end

