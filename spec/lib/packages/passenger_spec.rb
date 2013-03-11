require 'spec_helper'

describe 'packages/passenger' do
  before(:each) do
    $conf.user_home = '/home/user'
    $conf.from_hash(:passenger => {:version => '3.0.7'})
    $conf.from_hash(:ruby => {:gems_path => 'ruby/gems', :executable => 'bin/ruby'})
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   passenger - Install passenger",
      'SUDO   apt-get -q -y install libcurl4-openssl-dev',
      'RUN    gem install passenger -v "3.0.7"',
    ]
  end

  it 'sets passenger root and ruby' do
    eval_package
    $conf.passenger.root.must_equal '/home/user/ruby/gems/passenger-3.0.7'
    $conf.passenger.ruby.must_equal '/home/user/bin/ruby'
  end
end

