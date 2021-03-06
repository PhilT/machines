module Machines
  class Commandline

    def initialize
      @core = Core.new
    end

    # Execute a command (build dryrun generate htpasswd packages override tasks)
    def self.execute options
      help = Help.new
      action = options.shift
      if help.actions.include?(action)
        new.send action.gsub('new', 'generate'), options
      else
        say help.syntax
      end
    end

    # Loads Machinesfile, opens an SCP connection and runs all commands and file uploads
    def build options
      $conf.machine_name = options.shift
      return say(Help.new.syntax) unless $conf.machine_name
      init
      @core.package 'Machinesfile'

      @core.task options if options.any?

      ssh_options = {:paranoid => false}
      if $conf.machine.cloud
        username = $conf.machine.cloud.username
        ssh_options[:keys] = [$conf.machine.cloud.private_key_path]
      else
        username = $conf.machine.user
        ssh_options[:password] = $conf.password
      end

      if $conf.log_only
        $conf.commands.each do |command|
          command.run
        end
      else
        Kernel.trap("INT") { prepare_to_exit }
        begin
          Command.ssh = Net::SSH.start $conf.machine.address, username, ssh_options
          Command.scp = Net::SCP.new(Command.ssh)
          $conf.commands.each do |command|
            command.run
            Command.file.flush
            exit if $exit_requested
          end
        rescue Errno::ETIMEDOUT => e
          say e.message
          say 'Check the IP address in machines.yml'
        ensure
          Command.ssh.close if Command.ssh
        end
      end
    end

    def dryrun options
      $conf.log_only = true
      build options
    end

    def generate options
      dir = options.first || './'
      if File.exists? dir
        confirm = ask "Overwrite '#{dir}' (y/n)? "
        return unless confirm.downcase == 'y'
      end
      FileUtils.cp_r(File.join($conf.application_dir, 'template', '/.'), dir)
      FileUtils.mkdir_p(File.join(dir, 'packages'))
      say "Project created at #{dir}/"
    end

    def htpasswd options
      path = File.join($conf.webserver, 'htpasswd')
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
      $conf.passwords = []
      $conf.commands = []
      $conf.tasks = {}
      $conf.load('config.yml')

      Command.file ||= Logger.new File.open('log/output.log', 'w')
      Command.debug ||= Logger.new File.open('log/debug.log', 'w')
      Command.console ||= Logger.new STDOUT, :truncate => true
    end

    def list notused
      say Help.new.machine_list
    end

    def packages notused
      say 'Default packages'
      Dir[File.join($conf.application_dir, 'packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
      say ''

      say 'Project packages'
      Dir[File.join('packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
    end

    def override package
      package = package.first
      destination = File.join('packages', "#{package}.rb")
      answer = File.exists?(destination) ? ask('Project package already exists. Overwrite? (y/n)') : 'y'
      if answer == 'y'
        source = File.join($conf.application_dir, 'packages', "#{package}.rb")
        FileUtils.cp(source, destination)
        say "Package copied to #{destination}"
      else
        say 'Aborted.'
      end
    end

    def tasks options
      $conf.machine_name = options.shift
      return say(Help.new.syntax) unless $conf.machine_name

      $conf.log_only = true
      init
      @core.package 'Machinesfile'
      say 'Tasks'
      $conf.tasks.each do |task_name, settings|
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

