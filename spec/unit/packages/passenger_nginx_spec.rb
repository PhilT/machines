require 'spec_helper'

describe 'packages/passenger_nginx' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/passenger_nginx.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.from_hash(:nginx => {:destination => 'nginx_dest', :version => '1.0.2'})
  end

  it 'adds the following commands' do
    eval @package
    AppConf.commands.map(&:info).should == [
      "RUN    passenger-install-nginx-module --auto --prefix=nginx_dest --nginx-source-dir=/tmp/nginx-1.0.2 --extra-configure-flags=--with-http_ssl_module"
    ]
  end
end

