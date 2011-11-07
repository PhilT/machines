require 'spec_helper'

describe 'packages/passenger_nginx' do
  before(:each) do
    load_package('passenger_nginx')
    AppConf.from_hash(:webserver => {:path => 'nginx_dest', :version => '1.0.2'})
    AppConf.password = 'pass'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   passenger_nginx - Install Passenger Nginx module",
      "RUN    echo pass | rvmsudo -S passenger-install-nginx-module --auto --prefix=nginx_dest --nginx-source-dir=/tmp/nginx-1.0.2 --extra-configure-flags=--with-http_ssl_module"
    ]
  end
end

