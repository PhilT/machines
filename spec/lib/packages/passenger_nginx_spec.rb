require 'spec_helper'

describe 'packages/passenger_nginx' do
  before(:each) do
    $conf.from_hash(:webserver => {:path => 'nginx_dest', :version => '1.0.2'})
    $passwords.password = 'pass'
    $conf.from_hash(:passenger => {:root => '/home/user/gems/passenger-1.2.3'})
    $conf.from_hash(:ruby => {:gems_path => 'lib/ruby/gems/1.9.1/gems'})
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   passenger_nginx - Build the passenger module for Nginx",
      'RUN    cd /home/user/gems/passenger-1.2.3/ext/nginx && rake nginx RELEASE=yes && cd -'
    ]
  end
end

