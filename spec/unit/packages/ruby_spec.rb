require 'spec_helper'

describe 'packages/ruby' do
  before(:each) do
    load_package('ruby')
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.ruby = AppConf.new
    AppConf.ruby.version = '1.9.2'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   ruby - Install Ruby",
      "RUN    rvm install 1.9.2",
      "RUN    rvm 1.9.2 --default",
      "SUDO   echo \"gem: --no-rdoc --no-ri\" >> /etc/gemrc"
    ]
  end
end

