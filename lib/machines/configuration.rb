module Machines
  module Configuration
    # Add a new user (uses a lowlevel add so doesn't set a password. Used to handle authorized_keys files)
    # @param [String] login User name to create
    # @param [Hash] options
    # @option options [String] :password
    def add_user login, options = {}
      password = "-p #{`openssl passwd #{options[:password]}`.gsub("\n", '')} " if options[:password]
      admin = "-G admin " if options[:admin]
      Command.new(
        "useradd -s /bin/bash -d /home/#{login} -m #{password}#{admin}#{login}",
        check_dir("/home/#{login}")
      )
    end

    # Sets gconf key value pairs
    # @param [Hash] options One or many key/value pairs to set
    def configure options
      options.map do |key, value|
        types = {String => 'string', Fixnum => 'int', TrueClass => 'bool',
          FalseClass => 'bool', Float => 'float', Array => 'list --list-type=string'}
        type = types[value.class]
        raise 'Invalid type for configure' unless type
        value = value.to_json if value.is_a?(Array)
        value = %("#{value}") if type == 'string'
        check = "gconftool-2 --get \"#{key}\" | grep #{value} #{echo_result}"
        Command.new("gconftool-2 --set \"#{key}\" --type #{type} #{value}", check)
      end
    end

    # Removes a user, home and any other related files
    # @param [String] login User name to remove
    def del_user login
      Command.new("deluser #{login} --remove-home -q", check_file('/home/login', false))
    end
  end
end

