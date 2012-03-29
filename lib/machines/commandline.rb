module Machines
  module Commandline
    # Loads Machinesfile, opens an SCP connection and runs all commands and file uploads
    def build options
      AppConf.machine_name = options.shift
      AppConf.task = options.shift
      init
      load_machinesfile

      task AppConf.task.to_sym if AppConf.task

      if AppConf.machine.cloud
        username = AppConf.machine.cloud.username
        scp_options = {:keys => [AppConf.machine.cloud.private_key_path]}
      else
        username = AppConf.user
        scp_options = {:password => AppConf.password}
      end

      if AppConf.log_only
        AppConf.commands.each do |command|
          command.run
        end
      else
        Kernel.trap("INT") { prepare_to_exit }
        Net::SCP.start AppConf.address, username, scp_options do |scp|
          Command.scp = scp
          AppConf.commands.each do |command|
            command.run
            Command.file.flush
            exit if $exit_requested
          end
        end
      end
    end

    def dryrun options
      AppConf.log_only = true
      build options
    end

    # Execute a given command e.g. dryrun, build, generate, htpasswd, packages, override, tasks
    def execute(options, help)
      action = options.shift
      if help.actions.include?(action)
        action = 'generate' if action == 'new'
        send action, options
      else
        say help.syntax
      end
    end

    def generate options
      dir = options.first || './'
      if File.exists? dir
        confirm = ask "Overwrite '#{dir}' (y/n)? "
        return unless confirm.downcase == 'y'
      end
      FileUtils.cp_r(File.join(AppConf.application_dir, 'template', '/.'), dir)
      FileUtils.mkdir_p(File.join(dir, 'packages'))
      say "Project created at #{dir}/"
    end

    def htpasswd options
      path = File.join(AppConf.webserver, 'conf', 'htpasswd')
      say "Generate BasicAuth password and add to #{path}"
      username = ask('Username: ')
      password = enter_password 'users'

      crypted_pass = password.crypt(WEBrick::Utils.random_string(2))
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'a') {|file| file.puts "#{username}:#{crypted_pass}" }
      say "Password encrypted and added to #{path}"
    end

    def init
      $exit_requested = false
      AppConf.passwords = []
      AppConf.commands = []
      AppConf.webapps = {}
      AppConf.tasks = {}
      AppConf.load('config.yml')

      Command.file ||= Machines::Logger.new File.open('log/output.log', 'w')
      Command.debug ||= Machines::Logger.new File.open('log/debug.log', 'w')
      Command.console ||= Machines::Logger.new STDOUT, :truncate => true
    end

    def load_machinesfile
      eval File.read('Machinesfile'), nil, "eval: Machinesfile"
    rescue LoadError => e
      if e.message =~ /Machinesfile/
        raise LoadError, "Machinesfile does not exist. Use `machines new <DIR>` to create a template."
      else
        raise
      end
    end

    def packages
      say 'Default packages'
      Dir[File.join(AppConf.application_dir, 'packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
      say ''

      say 'Project packages'
      Dir[File.join('packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
    end

    def override package
      destination = File.join('packages', "#{package}.rb")
      answer = File.exists?(destination) ? ask('Project package already exists. Overwrite? (y/n)') : 'y'
      if answer == 'y'
        source = File.join(AppConf.application_dir, 'packages', "#{package}.rb")
        FileUtils.cp(source, destination)
        say "Package copied to #{destination}"
      else
        say 'Aborted.'
      end
    end

    def tasks
      AppConf.log_only = true
      init
      load_machinesfile
      say 'Tasks'
      AppConf.tasks.each do |task_name, settings|
        say "  %-20s #{settings[:description]}" % task_name
      end
    end

  private
    def prepare_to_exit
      exit if $exit_requested
      $exit_requested = true
      Command.console.log("\nEXITING after current command completes...", :color => :warning)
      Command.console.log("(Press again to terminate immediately)...", :color => :warning)
    end
  end
end

