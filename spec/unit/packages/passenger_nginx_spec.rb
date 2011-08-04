require 'spec_helper'

describe 'packages/passenger_nginx' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    load_package('passenger_nginx')
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.from_hash(:nginx => {:path => 'nginx_dest', :version => '1.0.2'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "RUN    passenger-install-nginx-module --auto --prefix=nginx_dest --nginx-source-dir=/tmp/nginx-1.0.2 --extra-configure-flags=--with-http_ssl_module"
    ]
  end
end

