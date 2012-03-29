require 'spec_helper'

describe 'packages/nginx' do
  before(:each) do
    load_package('nginx')
    AppConf.from_hash(:webserver => {:name => 'nginx', :version => '1.0.2', :path => 'nginx_path',
      :url => 'nginx_url/package', :src_path => '/usr/local/src/nginx-1.2.3', :modules => '--with-http_ssl_module'})
    AppConf.from_hash(:passenger => {:nginx => '/passenger/path/ext/nginx'})
    FileUtils.mkdir_p 'nginx'
    File.open('nginx/nginx.conf.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands' do
    AppConf.environment = :staging
    eval_package
    AppConf.commands.map(&:info).must_equal [
      "TASK   nginx - Download and configure Nginx",
      "SUDO   cd /usr/local/src && wget nginx_url/package && tar -zxf package && rm package && cd -",
      'SUDO   cd /usr/local/src/nginx-1.2.3 && ./configure --with-http_ssl_module --add-module=/passenger/path/ext/nginx',
      "UPLOAD buffer from nginx upstart to /tmp/nginx.conf",
      "SUDO   cp -rf /tmp/nginx.conf /etc/init/nginx.conf",
      "RUN    rm -rf /tmp/nginx.conf",
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

