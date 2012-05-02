require 'spec_helper'

describe 'packages/timezone' do
  before(:each) do
    load_package('timezone')
    $conf.timezone = 'GB'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   timezone - Set timezone from config.yml",
      "SUDO   ln -sf /etc/localtime /usr/share/zoneinfo/GB"
    ]
  end

  it 'UTC set when specified' do
    $conf.clock_utc = true
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   timezone - Set timezone from config.yml",
      "SUDO   ln -sf /etc/localtime /usr/share/zoneinfo/GB",
      "SUDO   sed -i \"s/UTC=no/UTC=yes/\" /etc/default/rcS"
    ]
  end
end

