require 'spec_helper'

describe 'packages/chrome' do
  before(:each) do
    load_package('chrome')
  end

  it 'adds chrome ppa and installs' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   chrome - Add chrome stable repo and installs (set use_opensource to use chromium)",
      "SUDO   echo deb http://dl.google.com/linux/deb/ stable main >> /etc/apt/sources.list",
      "SUDO   wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O - | apt-key add -",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install google-chrome-stable"
    ]
  end

  it 'adds chromium ppa and installs' do
    $conf.use_opensource = true
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   chrome - Add chrome stable repo and installs (set use_opensource to use chromium)",
      "SUDO   add-apt-repository ppa:chromium-daily/stable",
      "SUDO   apt-get -q -y update > /tmp/apt-update.log",
      "SUDO   apt-get -q -y install chromium-browser"
    ]
  end
end

