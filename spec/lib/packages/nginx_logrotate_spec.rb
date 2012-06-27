require 'spec_helper'

describe 'packages/nginx_logrotate' do
  before(:each) do
    load_package('nginx_logrotate')
    $conf.webapps = {'name' => AppBuilder.new({:name => 'appname', :path => 'apppath'})}
    FileUtils.mkdir_p 'logrotate'
    File.open('logrotate/nginx.erb', 'w') {|f| f.puts 'nginx template' }
    File.open('logrotate/app.erb', 'w') {|f| f.puts 'app template' }
  end

  it 'generates command' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      'TASK   logrotate_nginx - Logrotate nginx access and error logs and optionally generate stats',
      "UPLOAD buffer from logrotate/nginx.erb to /tmp/appname_nginx_access",
      "SUDO   cp -rf /tmp/appname_nginx_access /etc/logrotate.d/appname_nginx_access",
      "RUN    rm -rf /tmp/appname_nginx_access",
      "UPLOAD buffer from logrotate/nginx.erb to /tmp/appname_nginx_error",
      "SUDO   cp -rf /tmp/appname_nginx_error /etc/logrotate.d/appname_nginx_error",
      "RUN    rm -rf /tmp/appname_nginx_error",
      'TASK   logrotate_apps - Logrotate Rails app logs',
      "UPLOAD buffer from logrotate/app.erb to /tmp/appname_app",
      "SUDO   cp -rf /tmp/appname_app /etc/logrotate.d/appname_app",
      "RUN    rm -rf /tmp/appname_app",
    ]
  end

  describe 'nginx logs template' do
    before(:each) do
      nginx_template = nil
      RealFS do
        nginx_template = File.read 'lib/template/logrotate/nginx.erb'
      end
      File.open('logrotate/nginx.erb', 'w') {|f| f.puts nginx_template }
    end

    describe 'when awstats set' do
      it 'generates stats command' do
        skip
        settings = stub 'AppBuilder'
        stats_prerotate = '/usr/lib/cgi-bin/awstats.pl -update -config=appname stats_path/appname > /dev/null'
        stats_postrotate = '/usr/local/bin/awstats_render riskplatform.insidemedia.net /home/risk/riskplatform_stats/public > /dev/null'
        options = {:log_path => '/var/log/nginx/appname.access.log', stats_prerotate: stats_prerotate, stats_postrotate: stats_postrotate}
        AppBuilder.stubs(:new)
        AppBuilder.expects(:new).with(options).returns settings
        options = {:log_path => '/var/log/nginx/appname.error.log', stats_prerotate: nil, stats_postrotate: nil}
        AppBuilder.expects(:new).with(options).returns settings
        options = {:settings => settings, :to => '/etc/logrotate.d/appname_nginx_access'}
        expects(:create_from).with('logrotate/nginx.erb', options).returns Command.new 'command', 'check'
        eval_package
      end
    end

    describe 'when awstats not set' do
      it 'does not generate stats command' do
        skip
        settings = stub 'AppBuilder'
        AppBuilder.stubs(:new)
        options = {:log_path => '/var/log/nginx/appname.access.log', :stats_command => nil}
        AppBuilder.expects(:new).with(options).returns settings
        options = {:settings => settings, :to => '/etc/logrotate.d/appname_nginx_access'}
        expects(:create_from).with('logrotate/nginx.erb', options).returns Command.new 'command', 'check'
        eval_package
      end
    end
  end
  describe 'apps logs template' do
    it 'generates correct template' do
      mock_settings = mock 'AppBuilder'
      stubs(:create_from).returns Command.new 'command', 'check'
      AppBuilder.stubs(:new)
      AppBuilder.expects(:new).with(:log_path => 'apppath/shared/log/*.log').returns mock_settings
      options = {:settings => mock_settings, :to => '/etc/logrotate.d/appname_app'}
      expects(:create_from).with('logrotate/app.erb', options).returns Command.new 'command', 'check'
      eval_package
    end
  end
end

