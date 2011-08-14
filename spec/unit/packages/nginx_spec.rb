require 'spec_helper'

describe 'packages/nginx' do
  before(:each) do
    load_package('nginx')
    AppConf.log = mock 'Logger', :puts => nil
    AppConf.from_hash(:nginx => {:version => '1.0.2', :path => 'nginx_path', :url => 'nginx_url'})
    FileUtils.mkdir_p '/prj/nginx'
    File.open('/prj/nginx/nginx.conf.erb', 'w') {|f| f.puts 'the template' }
    @time = Time.now
    Time.stub(:now).and_return @time
  end

  it 'adds the following commands' do
    AppConf.environment = :staging
    eval_package
    AppConf.commands.map(&:info).should == [
      'TASK   nginx - Download and configure Nginx',
      "RUN    cd /tmp && wget nginx_url && tar -zxf nginx_url && rm nginx_url && cd -",
      "UPLOAD init.d/nginx to upload#{@time.to_i}",
      "SUDO   cp upload#{@time.to_i} /etc/init.d/nginx",
      "RUN    rm -f upload#{@time.to_i}",
      "SUDO   /usr/sbin/update-rc.d -f nginx defaults",
      "SUDO   echo \"the template\n\" > nginx_path/conf/nginx.conf",
      'TASK   htpasswd - Upload htpasswd file',
      "UPLOAD nginx/conf/htpasswd to upload#{@time.to_i}",
      "SUDO   cp upload#{@time.to_i} nginx_path/conf/htpasswd",
      "RUN    rm -f upload#{@time.to_i}",
      "SUDO   chmod 400 nginx_path/conf/htpasswd"
    ]
  end
end

