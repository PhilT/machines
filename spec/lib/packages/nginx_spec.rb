require 'spec_helper'

describe 'packages/nginx' do
  before(:each) do
    load_package('nginx')
    AppConf.from_hash(:nginx => {:version => '1.0.2', :path => 'nginx_path', :url => 'nginx_url'})
    FileUtils.mkdir_p 'nginx'
    File.open('nginx/nginx.conf.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands' do
    AppConf.environment = :staging
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   nginx - Download and configure Nginx",
      "RUN    cd /tmp && wget nginx_url && tar -zxf nginx_url && rm nginx_url && cd -",
      "UPLOAD nginx/initd to /tmp/nginx",
      "SUDO   cp -rf /tmp/nginx /etc/init.d/nginx",
      "RUN    rm -rf /tmp/nginx",
      "SUDO   /usr/sbin/update-rc.d -f nginx defaults",
      "SUDO   mkdir -p nginx_path/conf",
      "UPLOAD buffer from nginx/nginx.conf.erb to /tmp/nginx.conf",
      "SUDO   cp -rf /tmp/nginx.conf nginx_path/conf/nginx.conf",
      "RUN    rm -rf /tmp/nginx.conf",
      "TASK   htpasswd - Upload htpasswd file",
      "UPLOAD nginx/conf/htpasswd to /tmp/htpasswd",
      "SUDO   cp -rf /tmp/htpasswd nginx_path/conf/htpasswd",
      "RUN    rm -rf /tmp/htpasswd",
      "SUDO   chmod 400 nginx_path/conf/htpasswd"
    ]
  end
end

