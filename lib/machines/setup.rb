module Machines
  module Setup
    AppConf.commands = []
    AppConf.template_path = File.join(File.dirname(__FILE__), '..', 'template')

=begin
    These all need to be setup

    AppConf.dotfiles
    AppConf.machinename
    AppConf.environment
    AppConf.timezone
    AppConf.webserver

    AppConf.user.name
    AppConf.user.home
    AppConf.user.appsroot

    AppConf.nginx.url
=end
  end
end

