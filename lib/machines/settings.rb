module Machines
  module Settings
    AppConf.commands = []
    AppConf.template_path = File.join(File.dirname(__FILE__), '..', 'template')

    AppConf.from_hash({:log => {:progress => Logger.new(STDOUT), :output => Logger.new('log/output.log')}})
    AppConf.log.progress.formatter = AppConf.log.output.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n"}

    AppConf.webserver = 'nginx'

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

