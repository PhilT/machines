require 'spec_helper'

describe 'packages/dwm' do
  before do
    $conf.dwm = AppConf.new
    $conf.dwm.version = '6.0'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   dwm - Download, compile and install dwm",
      "SUDO   apt-get -q -y install build-essential",
      "SUDO   apt-get -q -y install libx11-dev",
      "SUDO   apt-get -q -y install libxinerama-dev",
      "SUDO   apt-get -q -y install sharutils",
      "SUDO   cd /tmp && wget http://dl.suckless.org/dwm/dwm-6.0.tar.gz && tar -zxf dwm-6.0.tar.gz && rm dwm-6.0.tar.gz && cd -",
      "SUDO   mv -f /tmp/dwm-6.0 /usr/local/src",
      "SUDO   cd /usr/local/src/dwm-6.0 && make clean install"
    ].join("\n")
  end
end

