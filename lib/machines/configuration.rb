module Machines
  module Configuration
    # Add a machine configuration
    def machine name, environment, options = {:apps => [], :roles => []}
      if name == AppConf.machine
        load_settings environment, options[:apps], options[:roles]
      end
    end

    # Add some text to the end of a file
    # @param [String] line Line of text to add
    # @param [Hash] options
    # @option options [String] :to File to append to
    def append line, options
      Command.new("echo '#{line}' >> #{options[:to]}", check_string(line, options[:to]))
    end

    # overwrite a file with the specified content
    # @param [String] line Line of text to add
    # @param [Hash] options
    # @option options [String] :to File to write to
    def write line, options
      Command.new("echo '#{line}' > #{options[:to]}", check_string(line, options[:to]))
    end

    # Export key/value pairs to a file
    # @param [Hash] options Keys to be exported
    # @option options [String] :to File to export key(s) to
    def export options
      required_options options, [:to]
      options.reject{|k, v| k == :to }.map do |key, value|
        command = "export #{key}=#{value}"
        Command.new("echo '#{command}' >> #{options[:to]}", check_string(command, options[:to]))
      end
    end

    # Sets gconf key value pairs
    # @param [Hash] options One or many key/value pairs to set
    def configure options
      options.map do |key, value|
        types = {String => 'string', Fixnum => 'int', TrueClass => 'bool', FalseClass => 'bool', Float => 'float', Array => 'list --list-type=string'}
        type = types[value.class]
        raise 'Invalid type for configure' unless type
        value = value.to_json if value.class = Array
        Command.new("gconftool-2 --set '#{key}' --type #{type} #{value}", nil)
      end
    end

    # Add a new user (uses a lowlevel add so doesn't set a password. Used to handle authorized_keys files)
    # @param [String] login User name to create
    # @param [Hash] options
    # @option options [String] :password
    def add_user login, options = {}
      password = "-p #{`openssl passwd #{options[:password]}`.gsub("\n", '')} " if options[:password]
      admin = "-G admin " if options[:admin]
      Command.new("useradd -s /bin/bash -d /home/#{login} -m #{password}#{admin}#{login}", check_dir("/home/#{login}"))
    end

    # Removes a user, home and any other related files
    # @param [String] login User name to remove
    def del_user login
      Command.new("deluser #{login} --remove-home -q", check_file('/home/login', false))
    end
  end
end

