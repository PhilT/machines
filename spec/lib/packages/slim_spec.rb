require 'spec_helper'

describe 'packages/slim' do
  before(:each) do
    $conf.login_theme = 'custom'
    FileUtils.mkdir_p 'slim/themes'
    eval_package
  end

  it 'adds the following commands' do
    $conf.commands.map(&:info).must_equal [
      "TASK   slim - Install SLiM desktop manager",
      "SUDO   apt-get -q -y install slim",
      "UPLOAD slim/themes to /tmp/themes",
      "SUDO   cp -rf /tmp/themes/. /usr/share/slim/themes",
      "RUN    rm -rf /tmp/themes",
      "SUDO   sed -i \"s/debian-spacefun/custom/\" /etc/slim.conf"
    ]
  end
end

