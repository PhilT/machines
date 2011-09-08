module Machines
  module Core
    # If a block is given, store the task, describe it and log it
    # If no block is given, sets commands to only those of the specified task so they can be run standalone
    # @param [Symbol] name Name of the task
    # @param [String] description Describe the task
    # @param [Hash] options
    # @option options [Symbol, Array] :if Dependent tasks that must already have been added for this task to be added
    def task name, description = nil, options = {}, &block
      if block
        dependencies = [options[:if]].flatten
        return if options[:if] && (dependencies - AppConf.tasks.keys).any?
        store_task name, description, &block
        AppConf.commands << LogCommand.new(name, description)
        yield
      else
        AppConf.commands = []
        AppConf.tasks[name][:block].call
      end
    end

    def store_task name, description, &block
      AppConf.tasks[name] = {:description => description, :block => block}
    end

    def list_tasks
      AppConf.tasks.each do |name, task|
        say "  #{"%-20s" % name}#{task[:description]}"
      end
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
      commands = command_from_string(commands)
      AppConf.commands += commands.flatten
    end

    # Queue up command(s) using SUDO to run remotely
    # @param [Array] *commands Command(s) to run
    def sudo *commands
      commands = command_from_string commands
      commands.flatten.each do |command|
        if command.is_a?(Upload)
          temp_path = "/tmp/#{File.basename(command.remote)}"
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

    # Upload a file or directory using SCP
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

    def command_from_string commands
      commands.first.is_a?(String) ? [Command.new(commands[0], commands[1])] : commands
    end
  end
end

