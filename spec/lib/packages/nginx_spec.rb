require 'spec_helper'

describe 'packages/nginx' do
  before(:each) do
    load_package('nginx')
    $conf.from_hash(webserver: {name: 'nginx', version: '1.2.3',
      path: 'nginx_path', conf_path: 'conf', modules: '--with-http_ssl_module'})
    $conf.from_hash(:passenger => {:nginx => '/passenger/path/ext/nginx'})
    FileUtils.mkdir_p 'nginx'
    File.open('nginx/nginx.conf.erb', 'w') {|f| f.puts 'the template' }
    File.open('nginx/upstart.conf.erb', 'w') {|f| f.puts 'the template' }
  end

  it 'adds the following commands for staging environment' do
    $conf.environment = 'staging'
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   nginx - Download and configure Nginx",
      "SUDO   cd /usr/local/src && wget http://nginx.org/download/nginx-1.2.3.tar.gz && tar -xfz nginx-1.2.3.tar.gz && rm nginx-1.2.3.tar.gz && cd -",
      'SUDO   cd /usr/local/src/nginx-1.2.3 && ./configure --with-http_ssl_module --add-module=/passenger/path/ext/nginx && make && make install',
      "UPLOAD buffer from nginx/nginx.conf.erb to /tmp/nginx.conf",
      "SUDO   cp -rf /tmp/nginx.conf nginx_path/conf/nginx.conf",
      "RUN    rm -rf /tmp/nginx.conf",
      "UPLOAD buffer from nginx/upstart.conf.erb to /tmp/nginx.conf",
      "SUDO   cp -rf /tmp/nginx.conf /etc/init/nginx.conf",
      "RUN    rm -rf /tmp/nginx.conf"
    ].join("\n")
  end

  it 'adds the following commands for development environment' do
    $conf.environment = 'development'
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   nginx - Download and configure Nginx",
      "SUDO   cd /usr/local/src && wget http://nginx.org/download/nginx-1.2.3.tar.gz && tar -xfz nginx-1.2.3.tar.gz && rm nginx-1.2.3.tar.gz && cd -",
      'SUDO   cd /usr/local/src/nginx-1.2.3 && ./configure --with-http_ssl_module --add-module=/passenger/path/ext/nginx && make && make install',
      "UPLOAD buffer from nginx/nginx.conf.erb to /tmp/nginx.conf",
      "SUDO   cp -rf /tmp/nginx.conf nginx_path/conf/nginx.conf",
      "RUN    rm -rf /tmp/nginx.conf",
      "UPLOAD buffer from nginx/upstart.conf.erb to /tmp/nginx.conf",
      "SUDO   cp -rf /tmp/nginx.conf /etc/init/nginx.conf",
      "RUN    rm -rf /tmp/nginx.conf"
    ].join("\n")
  end
end

