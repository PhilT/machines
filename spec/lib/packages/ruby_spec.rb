require 'spec_helper'

describe 'packages/ruby' do
  before(:each) do
    load_package('ruby')
    AppConf.ruby = AppConf.new
    AppConf.ruby.version = '1.9.2'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   ruby - Install Ruby",
      "RUN    rvm install 1.9.2",
      "RUN    rvm 1.9.2 --default",
      "UPLOAD buffer from gemrc to /tmp/gemrc",
      "SUDO   cp /tmp/gemrc /etc/gemrc",
      "RUN    rm -f /tmp/gemrc"
    ]
  end
end

