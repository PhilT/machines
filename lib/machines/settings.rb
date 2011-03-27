module Machines
  module Settings
    AppConf.project_dir = Dir.pwd
    AppConf.application_dir = File.join(File.dirname(__FILE__), '..')
    AppConf.commands = []

    def load_settings(environment)
      AppConf.environment = environment
      AppConf.from_hash({:log => {:path => nil, :progress => nil, :output => nil}})
      AppConf.log.path = File.join(AppConf.project_dir, 'log', 'output.log')
      FileUtils.mkdir_p File.dirname(AppConf.log.path)
      AppConf.log.progress = Logger.new(STDOUT)
      AppConf.log.output = Logger.new(AppConf.log.path)
      AppConf.log.progress.formatter = AppConf.log.output.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n"}
      AppConf.user.home = File.join('/home', AppConf.user.name)
      AppConf.load(File.join(AppConf.project_dir, 'config/config.yml'), File.join(AppConf.project_dir, 'users/users.yml'))
      AppConf.appsroot = AppConf[AppConf.user.name].appsroot

      load_app_settings
    end

=begin
    These all need to be setup

    AppConf.dotfiles
    AppConf.machinename
    AppConf.machine
    AppConf.hostname
    AppConf.environment
    AppConf.timezone

    AppConf.user.name
    AppConf.user.pass
    AppConf.user.home
    AppConf.user.appsroot

    AppConf.nginx.url
=end
  end
end

