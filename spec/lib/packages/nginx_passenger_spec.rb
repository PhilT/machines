require 'spec_helper'

describe 'packages/nginx_passenger' do
  before(:each) do
    load_package('nginx_passenger')
    AppConf.from_hash(:nginx => {:path => 'nginx_dest', :version => '1.0.2'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   nginx_passenger - Install Passenger Nginx module",
      "RVMSUDO passenger-install-nginx-module --auto --prefix=nginx_dest --nginx-source-dir=/tmp/nginx-1.0.2 --extra-configure-flags=--with-http_ssl_module"
    ]
  end
end

