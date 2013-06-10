module Machines
  class Core
    include Commands::Checks
    include Commands::Configuration
    include Commands::Database
    include Commands::FileOperations
    include Commands::Installation
    include Commands::Questions
    include Commands::Services

    # If a block is given, store the task, log it and run it
    # If no block is given, sets commands to only those of the specified tasks so they can be run standalone
    # @param [Symbol, String, Array] name Name of the task or array of task names
    # @param [String] description Describe the task
    # @param [Hash] options
    # @option options [Symbol, Array] :if Dependent tasks that must already have been added for this task to be added
    def task name, description = nil, options = {}, &block
      if block
        dependencies = [options[:if]].flatten
        return if options[:if] && (dependencies - $conf.tasks.keys).any?
        store_task name, description, &block
        $conf.commands << LogCommand.new(name, description)
        yield
      else
        tasks = [name].flatten
        $conf.commands = []
        tasks.each do |name|
          $conf.tasks[name.to_sym][:block].call
        end
      end
    end

    def store_task name, description, &block
      $conf.tasks[name] = {:description => description, :block => block}
    end

    def generate_password
      WEBrick::Utils.random_string(20)
    end

    # Only executes the code if $conf parameters match what is given in args
    def only options, &block
      yield if matched(options)
    end

    # Does not execute the code if $conf parameters match what is given in args
    def except options, &block
      yield unless matched(options)
    end

    def load_app_settings(apps)
      AppSettings.new.load_app_settings(apps)
    end

    # Loads the Machinesfile or a package
    def package name
      if name == 'Machinesfile'
        custom_name = builtin_name = 'Machinesfile'
        error = "Cannot find 'Machinesfile'. Use `machines new` to create a template."
      else
        custom_name = File.join('packages', "#{name}.rb")
        builtin_name = File.join($conf.application_dir, 'packages', "#{name}.rb")
        error = "Cannot find custom or built-in package '#{name}'."
      end
      package = load_and_eval(custom_name) || load_and_eval(builtin_name)
      package || raise(LoadError, error, caller)
    end

    # Queue up command(s) to run remotely
    # @param [Array] commands Command(s) to run.
    # If first command is a string it creates a Command object using the first two strings as command and check
    def run *commands
      commands = command_from_string(commands)
      $conf.commands += commands.flatten
    end

    # Queue up command(s) using SUDO to run remotely
    # @param [Array] commands Command(s) to run
    def sudo *commands
      commands = command_from_string commands
      commands.flatten.each do |command|
        if command.is_a?(Upload)
          temp_path = "/tmp/#{File.basename(command.remote)}"
          dir_suffix = command.local.is_a?(String) && File.directory?(command.local) ? '/.' : ''
          remote_dest = command.remote
          command.remote = temp_path
          command.check = check_file(temp_path)
          run command
          sudo copy(temp_path + dir_suffix, remote_dest)
          run remove temp_path
        else
          command.use_sudo
          run command
        end
      end
    end

    # Upload a file or folder using SCP
    # Can be used with sudo or run
    # @param [String] local_source File or folder on the local machine
    # @param [String] remote_dest Folder on the remote machine to copy to
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

  #TODO: Move matched into separate class to test
    def matched options
      options.each do |key, value|
        value = value.is_a?(Array) ? value.map{|o| o.to_s } : value.to_s
        if $conf[key].is_a?(Array)
          values = $conf[key].map{|o| o.to_s }
          if value.is_a?(Array)
            return unless values.reject{ |symbol| !value.include?(symbol.to_s) }.any?
          else
            return unless values.include?(value)
          end
        else
          if value.is_a?(Array)
            return unless value.include?($conf[key].to_s)
          else
            return unless value == $conf[key].to_s
          end
        end
      end
      true
    end

  private
    def load_and_eval package_name
      if File.exists?(package_name)
        eval(File.read(package_name), nil, "eval: #{package_name}")
        true
      end
    end

    def command_from_string commands
      commands.first.is_a?(String) ? [Command.new(commands[0], commands[1])] : commands
    end

  end
end

