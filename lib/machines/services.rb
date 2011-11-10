module Machines
  module Services
    # Create an Upstart configuration file
    def add_upstart name, options = {}
      required_options options, [:description]
      options[:description] = %("#{options[:description]}")
      configuration = options.map do |option, value|
        value = value.is_a?(TrueClass) ? '' : " #{value}" unless option == :custom
        option = '' if option == :custom
        "#{option}#{value}\n"
      end.join
      write configuration, :to => "/etc/init/#{name}.conf", :name => "#{name} upstart"
    end

    # Stop a daemon
    def stop daemon
      Command.new("service #{daemon} stop", check_daemon(daemon, false))
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

