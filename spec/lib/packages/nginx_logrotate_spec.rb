require 'spec_helper'

describe 'packages/nginx_logrotate' do
  before(:each) do
    load_package('nginx_logrotate')
    AppConf.webapps = {'name' => AppBuilder.new({:name => 'appname', :path => 'apppath'})}
    FileUtils.mkdir_p 'logrotate'
    File.open('logrotate/nginx.erb', 'w') {|f| f.puts 'nginx template' }
    File.open('logrotate/app.erb', 'w') {|f| f.puts 'app template' }
  end

  it 'generates command' do
    eval_package
    AppConf.commands.map(&:info).should == [
      'TASK   logrotate_nginx - Logrotate nginx access and error logs and optionally generate stats',
      "UPLOAD buffer from logrotate/nginx.erb to /tmp/appname_nginx_access_log",
      "SUDO   cp -rf /tmp/appname_nginx_access_log /etc/logrotate.d/appname_nginx_access_log",
      "RUN    rm -rf /tmp/appname_nginx_access_log",
      "UPLOAD buffer from logrotate/nginx.erb to /tmp/appname_nginx_error_log",
      "SUDO   cp -rf /tmp/appname_nginx_error_log /etc/logrotate.d/appname_nginx_error_log",
      "RUN    rm -rf /tmp/appname_nginx_error_log",
      'TASK   logrotate_apps - Logrotate Rails app logs',
      "UPLOAD buffer from logrotate/app.erb to /tmp/appname_app_log",
      "SUDO   cp -rf /tmp/appname_app_log /etc/logrotate.d/appname_app_log",
      "RUN    rm -rf /tmp/appname_app_log",
    ]
  end

  describe 'nginx logs template' do
    before(:each) do
      AppConf.awstats = nil
      stub!(:create_from).and_return Command.new 'command', 'check'
    end

    context 'when awstats set' do
      before(:each) do
        AppConf.from_hash :awstats => {:url => 'url', :path => 'path', :stats_path => 'stats_path'}
      end

      it 'generates stats command' do
        mock_settings = mock AppBuilder
        command = <<-COMMAND
  sharedscripts
  prerotate
    /usr/lib/cgi-bin/awstats.pl -update -config=appname stats_path/appname > /dev/null
  endscript
  COMMAND
        options = {:log_path => '/var/log/nginx/appname.access.log', :stats_command => command}
        AppBuilder.should_receive(:new).with(options).and_return mock_settings
        options = {:log_path => '/var/log/nginx/appname.error.log', :stats_command => nil}
        AppBuilder.should_receive(:new).with(options).and_return mock_settings
        options = {:settings => mock_settings, :to => '/etc/logrotate.d/appname_nginx_access_log'}
        should_receive(:create_from).with('logrotate/nginx.erb', options).and_return Command.new 'command', 'check'
        eval_package
      end
    end

    context 'when awstats not set' do
      it 'does not generate stats command' do
        mock_settings = mock AppBuilder
        options = {:log_path => '/var/log/nginx/appname.access.log', :stats_command => nil}
        AppBuilder.should_receive(:new).with(options).and_return mock_settings
        options = {:settings => mock_settings, :to => '/etc/logrotate.d/appname_nginx_access_log'}
        should_receive(:create_from).with('logrotate/nginx.erb', options).and_return Command.new 'command', 'check'
        eval_package
      end
    end
  end
  describe 'apps logs template' do
    it 'generates correct template' do
      mock_settings = mock AppBuilder
      stub!(:create_from).and_return Command.new 'command', 'check'
      AppBuilder.stub(:new)
      AppBuilder.should_receive(:new).with(:log_path => 'apppath/shared/log/*.log').and_return mock_settings
      options = {:settings => mock_settings, :to => '/etc/logrotate.d/appname_app_log'}
      should_receive(:create_from).with('logrotate/app.erb', options).and_return Command.new 'command', 'check'
      eval_package
    end
  end
end

