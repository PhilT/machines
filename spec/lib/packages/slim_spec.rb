require 'spec_helper'

describe 'packages/slim' do
  before(:each) do
    AppConf.theme = 'custom'
    load_package('slim')
    FileUtils.mkdir_p 'slim/themes'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   slim - Install SLiM desktop manager",
      "SUDO   apt-get -q -y install slim",
      "UPLOAD slim/themes to /tmp/themes",
      "SUDO   cp -rf /tmp/themes/. /usr/share/slim/themes",
      "RUN    rm -rf /tmp/themes",
      "SUDO   sed -i s/debian-spacefun/custom/ /etc/slim.conf"
    ]
  end
end

