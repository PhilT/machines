require 'spec_helper'

describe 'packages/passenger' do
  before(:each) do
    load_package('passenger')
    AppConf.user_home = '/home/user'
    AppConf.from_hash(:passenger => {:version => '3.0.7'})
    AppConf.from_hash(:ruby => {:gems_path => 'ruby/gems', :executable => 'bin/ruby'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   passenger - Install passenger",
      'SUDO   apt-get -q -y install libcurl4-openssl-dev',
      'RUN    gem install passenger -v "3.0.7"',
    ]
  end

  it 'sets passenger root and ruby' do
    eval_package
    AppConf.passenger.root.should == '/home/user/ruby/gems/passenger-3.0.7'
    AppConf.passenger.ruby.should == '/home/user/bin/ruby'
  end
end

