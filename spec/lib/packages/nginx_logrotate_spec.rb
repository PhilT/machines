require 'spec_helper'

describe 'packages/nginx_logrotate' do
  before(:each) do
    $conf.webapps = {'name' => AppSettings::AppBuilder.new({:name => 'appname', :path => 'apppath'})}
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
      skip
      nginx_template = nil
      FakeFS.deactivate!
      nginx_template = File.read 'lib/template/logrotate/nginx.erb'
      FakeFS.activate!
      File.open('logrotate/nginx.erb', 'w') {|f| f.puts nginx_template }
    end

    describe 'when awstats set' do
      it 'generates stats command' do
        settings = stub 'AppBuilder'
        stats_prerotate = '/usr/lib/cgi-bin/awstats.pl -update -config=appname stats_path/appname > /dev/null'
        stats_postrotate = '/usr/local/bin/awstats_render riskplatform.insidemedia.net /home/risk/riskplatform_stats/public > /dev/null'
        options = {:log_path => '/var/log/nginx/appname.access.log', stats_prerotate: stats_prerotate, stats_postrotate: stats_postrotate}
        AppSettings::AppBuilder.stubs(:new)
        AppSettings::AppBuilder.expects(:new).with(options).returns settings
        options = {:log_path => '/var/log/nginx/appname.error.log', stats_prerotate: nil, stats_postrotate: nil}
        AppSettings::AppBuilder.expects(:new).with(options).returns settings
        options = {:settings => settings, :to => '/etc/logrotate.d/appname_nginx_access'}
        core.expects(:create_from).with('logrotate/nginx.erb', options).returns Command.new 'command', 'check'
        eval_package
      end
    end

    describe 'when awstats not set' do
      it 'does not generate stats command' do
        settings = stub 'AppBuilder'
        AppSettings::AppBuilder.stubs(:new)
        options = {:log_path => '/var/log/nginx/appname.access.log', :stats_command => nil}
        AppSettings::AppBuilder.expects(:new).with(options).returns settings
        options = {:settings => settings, :to => '/etc/logrotate.d/appname_nginx_access'}
        core.expects(:create_from).with('logrotate/nginx.erb', options).returns Command.new 'command', 'check'
        eval_package
      end
    end
  end

  describe 'apps logs template' do
    it 'generates correct template' do
      mock_settings = mock 'AppBuilder'
      core.stubs(:create_from).returns Machines::Command.new 'command', 'check'
      AppSettings::AppBuilder.stubs(:new)
      AppSettings::AppBuilder.expects(:new).with(:log_path => 'apppath/shared/log/*.log').returns mock_settings
      options = {:settings => mock_settings, :to => '/etc/logrotate.d/appname_app'}
      core.expects(:create_from).with('logrotate/app.erb', options).returns Command.new 'command', 'check'
      eval_package
    end
  end
end

