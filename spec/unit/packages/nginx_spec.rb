require 'spec_helper'

describe 'packages/nginx' do
  include Core
  include FileOperations
  include Configuration
  include Installation
  include Services
  include Machines::Logger

  before(:each) do
    FakeFS.deactivate!
    @package = File.read(File.join(AppConf.application_dir, 'packages/nginx.rb'))
    FakeFS.activate!
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.from_hash(:nginx => {:version => '1.0.2', :path => 'nginx_path', :url => 'nginx_url'})
    FileUtils.mkdir_p '/tmp/nginx'
    File.open('/tmp/nginx/nginx.conf.erb', 'w') {|f| f.puts 'the template' }
    @time = Time.now
    Time.stub(:now).and_return @time
  end

  it 'adds the following commands' do
    eval @package
    AppConf.commands.map(&:info).should == [
       "RUN    cd /tmp && wget nginx_url && tar -zxf nginx_url && rm nginx_url && cd -",
       "UPLOAD init.d/nginx to upload#{@time.to_i}",
       "SUDO   cp upload#{@time.to_i} /etc/init.d/nginx",
       "RUN    rm -f upload#{@time.to_i}",
       "SUDO   /usr/sbin/update-rc.d -f nginx defaults",
       "RUN    echo \"the template\n\" > nginx_path/conf/nginx.conf",
       "UPLOAD nginx/conf/htpasswd to upload#{@time.to_i}",
       "SUDO   cp upload#{@time.to_i} nginx_path/conf/htpasswd",
       "RUN    rm -f upload#{@time.to_i}",
       "SUDO   chmod 400 nginx_path/conf/htpasswd"
    ]
  end
end

