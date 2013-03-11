require 'spec_helper'

describe 'packages/base' do
  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   base - Install base packages for compiling Ruby and libraries",
      "SUDO   apt-get -q -y install build-essential",
      "SUDO   apt-get -q -y install zlib1g-dev",
      "SUDO   apt-get -q -y install libpcre3-dev",
      "SUDO   apt-get -q -y install ruby1.9.1-dev",
      "SUDO   apt-get -q -y install libreadline-dev",
      "SUDO   apt-get -q -y install libxml2-dev",
      "SUDO   apt-get -q -y install libxslt1-dev",
      "SUDO   apt-get -q -y install libssl-dev",
      "SUDO   apt-get -q -y install libncurses5-dev"
    ].join("\n")
  end
end

