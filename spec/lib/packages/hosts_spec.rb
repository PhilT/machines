require 'spec_helper'

describe 'packages/hosts' do
  before(:each) do
    load_package('hosts')
    $conf.machine = AppConf.new
    $conf.machine.hostname = 'hostname'
    $conf.from_hash(:hosts => {'some.domain' => '1.2.3.4'})
    @hosts = [
      "TASK   hosts - Setup /etc/hosts",
      "UPLOAD unnamed buffer to /tmp/hosts",
      "SUDO   cp -rf /tmp/hosts /etc/hosts",
      "RUN    rm -rf /tmp/hosts",
      "UPLOAD unnamed buffer to /tmp/hostname",
      "SUDO   cp -rf /tmp/hostname /etc/hostname",
      "RUN    rm -rf /tmp/hostname",
      "SUDO   service hostname start",
      "SUDO   grep \"1.2.3.4 some.domain\" /etc/hosts || echo \"1.2.3.4 some.domain\" >> /etc/hosts",
    ]
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal (@hosts).join("\n")
  end

  it 'does not add hosts when nil' do
    $conf.clear :hosts
    @hosts.pop
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal (@hosts).join("\n")
  end

  it 'does not add host when address is nil' do
    $conf.from_hash(:hosts => {'some.domain' => nil})
    @hosts.pop
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal (@hosts).join("\n")
  end
end

