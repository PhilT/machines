require 'spec_helper'

describe 'packages/timezone' do
  before(:each) do
    $conf.timezone = 'GB'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   timezone - Set timezone from config.yml",
      "SUDO   ln -sf /usr/share/zoneinfo/GB /etc/localtime"
    ]
  end

  it 'UTC set when specified' do
    $conf.clock_utc = true
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   timezone - Set timezone from config.yml",
      "SUDO   ln -sf /usr/share/zoneinfo/GB /etc/localtime",
      "SUDO   sed -i \"s/UTC=no/UTC=yes/\" /etc/default/rcS"
    ]
  end
end

