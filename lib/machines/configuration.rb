module Machines
  module Configuration

    # Add some text to the end of a file
    # @param [String] line Line of text to add
    # @param [Hash] options
    # @option options [String] :to File to append to
    def append line, options
      add "echo '#{line}' >> #{options[:to]}", check_string(line, options[:to])
    end

    # Export key/value pairs and optionally write to a file
    # @param [Hash] options Keys to be exported
    # @option options [String] :to File to export key(s) to
    def export options
      required_options options, [:to]
      commands = []
      options.each do |key, value|
        unless key == :to
          command = "export #{key}=#{value}"
          add "echo '#{command}' >> #{options[:to]}", check_string(command, options[:to])
        end
      end
    end

    # Add a new user (uses a lowlevel add so doesn't set a password. Used to handle authorized_keys files)
    # @param [String] login User name to create
    def add_user login
      add "useradd #{login}", check_file('/home/login')
    end

    # Removes a user, home and any other related files
    # @param [String] login User name to remove
    def del_user login
      add "deluser #{login} --remove-all-files", check_file('/home/login', false)
    end

  end
end

