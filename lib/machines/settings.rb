require 'settings/app_settings'

module Machines
  module Settings
    AppConf.project_dir = Dir.pwd
    AppConf.load(File.join(AppConf.project_dir, 'config/config.yml'))
    AppConf.commands = []
    AppConf.template_path = File.join(File.dirname(__FILE__), '..', 'template')
    AppConf.from_hash({:log => {:progress => Logger.new(STDOUT), :output => Logger.new('log/output.log')}})
    AppConf.log.progress.formatter = AppConf.log.output.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n"}
    AppConf.user.home = File.join('/home', AppConf.user.name)

    AppSettings.load
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

