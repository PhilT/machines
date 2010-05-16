module Machines
  module Services
    # Upload an /etc/init.d script and run update-rc.d
    # @param [String] name init.d script to upload and register
    def add_init_d name
      upload "init.d/#{name}", "/etc/init.d/#{name}"
      add "/usr/sbin/update-rc.d -f #{name} defaults"
    end

    # Restart a daemon
    # @param [String] daemon Name of the init.d daemon to restart
    def restart daemon
      add "/etc/init.d/#{daemon} restart"
    end
  end
end

