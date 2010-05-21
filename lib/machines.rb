require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'yaml'
require 'active_support'
require 'colors'
# Machines allows simple configuration of development, staging and production computers or images for ec2

module Machines
  DEFAULT_IDENTITY = 'ubuntu'
  TEMP_PASSWORD = 'ubuntu'
  TEMP_PASSWORD_ENCRYPTED = "tvXbD6sWjb4mE"
  DEFAULT_USERNAME = 'www'

  class Base
    Dir[File.join(File.dirname(__FILE__), 'machines/**/*.rb')].sort.each { |lib| require lib; include eval(File.basename(lib, '.rb').camelize) }

    def ssh_options(options)
      {:user_known_hosts_file => %w(/dev/null), :paranoid => false}.merge(options)
    end

    # Takes the arguments given on the commandline except the <command>. Set defaults.
    # @param options [Hash]
    # @option options [String] :machine one of the configurations specified in Machinesfile
    # @option options [String] :host the url of the remote machine
    # @option options [String] :password the password. Must be encrypted. Use 'openssl passwd <password>'
    # @option options [String] :dbmaster url to the master database server. Defaults to host
    # @option options [String] :machinename name to give the computer. Defaults to <machine>
    # @option options [String] :username the username. Defaults to 'www'
    def initialize options
      @commands = []
      @passwords = {}
      @config_name = options[:machine]
      @host = options[:host]
      @password = options[:password]
      @dbmaster = options[:dbmaster] || @host
      @machinename = options[:machinename] || @config_name
      @username = options[:username] || DEFAULT_USERNAME
      raise 'Password not set' unless @password
      discover_users
    end

    def test name
      load_machinesfile name
      run_commands
    end

    def install name
      load_machinesfile name
      prepare_log_file
      enable_root_login
      Net::SSH.start @host, 'root', ssh_options(:password => TEMP_PASSWORD) do |ssh|
        run_commands ssh
      end
      disable_root_login
    end

private

    def load_machinesfile name
      @config_name = name
      load File.join(Dir.pwd, 'Machinesfile')
    rescue LoadError
      puts "Machinesfile does not exist. Please create one."
      exit 1
    rescue NoMethodError
      puts "Have you selected the correct machine configuration?"
      raise
    end


    def discover_users
      @users = Dir['users/*'].map{|file| File.basename file}
    end

    # Loops through all commands calling with either Net::SSH::exec! or Net::SCP::upload!
    # @param [Optional #exec!] ssh Net::SSH connection to send the commands to. Only output them if ssh is nil
    def run_commands net_ssh = nil
      count = @commands.size.to_f
      i = 1
      STDOUT.sync = true
      @failed = false
      @commands.each do |line, command, check|
        raise ArgumentError, "MISSING name or command in: [#{line}, #{display(command)}]" unless line && command
        progress = i / count * 100
        i += 1
        if net_ssh
          bar = "\r#{" %-4s" % (progress.to_i.to_s + '%')} " + ("[#{"%-100s" % ('=' * progress)}]")
          print @failed ? bar.red : bar.green
          log_to :file, "Machinesfile line #{line})".blue
          log_to :file, "#{command.is_a?(Array) ? 'Uploading' : 'Running'} #{display(command).orange}"
          upload_successful = true
          if command.is_a?(Array)
            begin
              Net::SCP.start @host, 'root', ssh_options(:password => TEMP_PASSWORD) do |scp|
                scp.upload! command[0], command[1]
              end
            rescue
              log_to :file, "FAILED\n\n".red
              upload_failed = true
            end
          else
            log_to :file, net_ssh.exec!(command)
          end
          failed = upload_failed || !log_result_to_file(check, net_ssh.exec!(check))
          @failed = true if failed
        else
          log_to :screen, "#{"%-4s" % (line + ')')} #{display(command)}"
        end
      end
      puts
    end

    # Set a root password so ssh can login
    def enable_root_login
      Net::SSH.start @host, DEFAULT_IDENTITY, ssh_options(:password => DEFAULT_IDENTITY) do |ssh|
        log_to :file, ssh.exec!("echo #{DEFAULT_IDENTITY} | sudo -S usermod -p #{TEMP_PASSWORD_ENCRYPTED} root")
      end
    end

    # Disable root login
    def disable_root_login
      Net::SSH.start @host, 'root', ssh_options(:password => TEMP_PASSWORD) do |ssh|
        log_to :file, ssh.exec!("passwd -l root")
      end
    end
  end
end

