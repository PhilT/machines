require 'spec_helper'

describe 'packages/passenger_nginx' do
  before(:each) do
    load_package('passenger_nginx')
    $conf.from_hash(:webserver => {:path => 'nginx_dest', :version => '1.0.2'})
    $conf.password = 'pass'
    $conf.from_hash(:passenger => {:root => '/home/user/gems/passenger-1.2.3'})
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   passenger_nginx - Build the passenger module for Nginx",
      'RUN    cd /home/user/gems/passenger-1.2.3/ext/nginx && rake nginx RELEASE=yes && cd -'
    ]
  end
end

