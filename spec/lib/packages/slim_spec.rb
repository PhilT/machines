require 'spec_helper'

describe 'packages/slim' do
  before(:each) do
    AppConf.theme = 'custom'
    load_package('slim')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   slim - Install SLiM desktop manager",
      "SUDO   apt-get -q -y install slim",
      "UPLOAD slim/themes to /tmp/themes",
      "SUDO   cp -f /tmp/themes /usr/share/slim/themes",
      "RUN    rm -f /tmp/themes",
      "SUDO   sed -i \"s/debian-spacefun/custom/\" /etc/slim.conf",
      "SUDO   ln -sf $HOME/Pictures/wallpaper.jpg /usr/share/slim/themes/custom/background.jpg"
    ]
  end
end

