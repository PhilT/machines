module Machines
  module Core
    # Executes a task in a package
    # Provides a way to describe parts of a package and log the status
    def task description, &block
      log description, :color => :info
      yield
    end

    # Only executes the code if AppConf parameters match what is given in args
    def only options, &block
      yield if matched(options)
    end

    # Does not execute the code if AppConf parameters match what is given in args
    def except options, &block
      yield unless matched(options)
    end

    def matched options
      options.each do |key, value|
        if AppConf[key].is_a?(Array)
          if value.is_a?(Array)
            return unless AppConf[key].reject{ |symbol| !value.include?(symbol) }.any?
          else
            return unless AppConf[key].include?(value)
          end
        else
          if value.is_a?(Array)
            return unless value.include?(AppConf[key])
          else
            return unless value == AppConf[key]
          end
        end
      end
      true
    end

    # Queue up command(s) to run remotely
    # @param [Array] *commands Command(s) to run.
    # If first command is a string it creates a Command object using the first two strings as command and check
    def run *commands
      commands = handle_strings(commands)
      AppConf.commands += commands.flatten
    end

    def handle_strings commands
      commands.first.is_a?(String) ? [Command.new(commands[0], commands[1])] : commands
    end

    # Queue up command(s) using SUDO to run remotely
    # @param [Array] *commands Command(s) to run
    def sudo *commands
      commands = handle_strings commands
      commands.flatten.each do |command|
        if command.is_a?(Upload)
          temp_path = "upload#{Time.now.to_i}"
          remote_dest = command.remote
          command.remote = temp_path
          command.check = check_file(temp_path)
          run command
          sudo copy(temp_path, remote_dest)
          run remove temp_path
        else
          command.use_sudo
          run command
        end
      end
    end

    # Upload a file or directory using SCP and optionally set permissions.
    # Can be used with sudo or run
    # @param [String] local_source File or directory on the local machine
    # @param [String] remote_dest Directory on the remote machine to copy to
    #     upload 'source_dir', '~' #=> creates source_dir/subdir as ~/subdir
    def upload local_source, remote_dest
      Upload.new(local_source, remote_dest, check_file(remote_dest))
    end

    # Validate some methods that require certain options
    def required_options options, required
      required.each do |option|
        raise ArgumentError, "Missing option '#{option}'. Check trace for location of the problem." unless options[option]
      end
    end
  end
end

