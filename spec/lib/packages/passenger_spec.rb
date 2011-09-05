require 'spec_helper'

describe 'packages/passenger' do
  before(:each) do
    load_package('passenger')
    AppConf.from_hash(:passenger => {:version => '3.0.7'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   passenger - Install passenger",
      'SUDO   apt-get -q -y install libcurl4-openssl-dev',
      'RUN    gem install passenger -v "3.0.7"'
    ]
  end
end

