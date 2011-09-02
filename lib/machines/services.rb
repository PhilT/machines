module Machines
  module Services
    # Upload an /etc/init.d script and run update-rc.d. Must be called with `sudo`
    # @param [String] name init.d script to upload and register
    def add_init_d name
      [
        upload(File.join(name, 'initd'), "/etc/init.d/#{name}"),
        Command.new("/usr/sbin/update-rc.d -f #{name} defaults", check_init_d(name))
      ]
    end

    # Start a daemon
    # @param [String] daemon Name of the service to start
    def start daemon
      Command.new("service #{daemon} start", check_daemon(daemon))
    end

    # Restart a daemon
    # @param [String] daemon Name of the service to restart
    def restart daemon
      Command.new("service #{daemon} restart", check_daemon(daemon))
    end
  end
end

