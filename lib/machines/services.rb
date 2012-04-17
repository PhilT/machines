module Machines
  module Services
    # Stop a daemon
    def stop daemon
      Command.new("service #{daemon} stop", check_daemon(daemon, false))
    end

    # Start a daemon
    # @param [String] daemon Name of the service to start
    # @param [Hash] options
    # @option options [Boolean] :check Set to false to disable the check (e.g. start hostname, :check => false)
    def start daemon, options = {}
      check = options[:check] || check_daemon(daemon)
      Command.new("service #{daemon} start", check)
    end

    # Restart a daemon
    # @param [String] daemon Name of the service to restart
    def restart daemon
      Command.new("service #{daemon} restart", check_daemon(daemon))
    end
  end
end

