require 'spec_helper'

describe 'packages/nginx' do
  before(:each) do
    load_package('nginx')
    AppConf.from_hash(:nginx => {:version => '1.0.2', :path => 'nginx_path', :url => 'nginx_url'})
    FileUtils.mkdir_p '/prj/nginx'
    File.open('/prj/nginx/nginx.conf.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands' do
    AppConf.environment = :staging
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   nginx - Download and configure Nginx",
      "RUN    cd /tmp && wget nginx_url && tar -zxf nginx_url && rm nginx_url && cd -",
      "UPLOAD nginx/initd to /tmp/nginx",
      "SUDO   cp /tmp/nginx /etc/init.d/nginx",
      "RUN    rm -f /tmp/nginx",
      "SUDO   /usr/sbin/update-rc.d -f nginx defaults",
      "SUDO   mkdir -p nginx_path/conf",
      "UPLOAD buffer from /prj/nginx/nginx.conf.erb to /tmp/nginx.conf",
      "SUDO   cp /tmp/nginx.conf nginx_path/conf/nginx.conf",
      "RUN    rm -f /tmp/nginx.conf",
      "TASK   htpasswd - Upload htpasswd file",
      "UPLOAD nginx/conf/htpasswd to /tmp/htpasswd",
      "SUDO   cp /tmp/htpasswd nginx_path/conf/htpasswd",
      "RUN    rm -f /tmp/htpasswd",
      "SUDO   chmod 400 nginx_path/conf/htpasswd"
    ]
  end
end

