# Machines allows simple configuration of development, staging and production computers or images for ec2
require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'active_support'
require 'yaml'
require File.join(File.dirname(__FILE__), 'colors')
require File.join(File.dirname(__FILE__), 'progress')

module Machines
  DEFAULT_IDENTITY = 'ubuntu'
  DEFAULT_USERNAME = 'www'

  class Base
    Dir[File.join(File.dirname(__FILE__), 'machines/**/*.rb')].sort.each do |lib|
      require lib; include eval(ActiveSupport::Inflector.camelize(File.basename(lib, '.rb')))
    end

    attr_reader :passwords, :host, :userpass, :dbmaster, :machinename, :username, :users, :passwords, :environment, :apps, :role

    # Takes the arguments given on the commandline except the <command>. Set defaults.
    # @param options [Hash]
    # @option options [String] :machine one of the configurations specified in Machinesfile
    # @option options [String] :host the url of the remote machine
    # @option options [Optional String] :password Password to setup for user account.
    # @option options [Optional String] :initial_password Passed used to first login to the remote machine. Defaults to 'ubuntu'
    # @option options [Optional String] :keyfile Path to the file containing the SSH key
    # @option options [Optional String] :dbmaster url to the master database server. Defaults to host
    # @option options [Optional String] :machinename name to give the computer. Defaults to <machine>
    # @option options [Optional String] :username the username. Defaults to 'www'
    def initialize(options)
      @commands = []
      @passwords = {}
      @config = options[:machine]
      @host = options[:host]
      @userpass = options[:userpass]
      @initial_password = options[:initial_password] || DEFAULT_IDENTITY
      @keys = [options[:keyfile]]
      @dbmaster = options[:dbmaster] || @host
      @machinename = options[:machinename] || @config
      @username = options[:username] || DEFAULT_USERNAME
      raise ArgumentError, 'Missing options. :machine, :host and :keyfile are required' unless @config && @host
    end

    def dryrun
      discover_users
      load_machinesfile
      run_commands
    end

    def setup
      discover_users
      load_machinesfile
      prepare_log_file
      setup_dev_machine if development?
      enable_root_login
      Net::SSH.start @host, 'root', :keys => @keys do |ssh|
        run_commands ssh
      end
      disable_root_login
    end

private

    def load_machinesfile
      machine 'selected', :test
      eval File.read('Machinesfile')
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
      progress = Progress.new(@commands.size)
      i = 1
      STDOUT.sync = true
      @failed = false
      @commands.each do |line, command, check|
        progress.advance

        if net_ssh
          bar = progress.show(line, command)
          print @failed ? bar.dark_red : bar.dark_green
          log_to :file, "Machinesfile line #{line}:".blue
          prefix = command.is_a?(Array) ? 'Upload' : 'Run'
          log_to :file, "#{prefix} #{display(command).orange}"
          upload_successful = true
          if command.is_a?(Array)
            begin
              Net::SCP.start @host, 'root', :keys => @keys do |scp|
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
          log_to :screen, "#{("%-6s" % (line + ':')).dark_blue} #{display(command)}"
          log_to :screen, check ? "#{'check:'.dark_green} #{display(check)}" : 'no check'.orange
        end
      end
      bar = progress.complete
      puts @failed ? bar.dark_red : bar.dark_green
    end

    # Creates a keypair on a dev machine and allows sudo without password to lineup with Ubuntu EC2 images and run the rest of the script
    def setup_dev_machine
      @keys = ["#{host}.key"]
      Net::SSH.start host, DEFAULT_IDENTITY, :password => @initial_password do |ssh|
        log_to :file, ssh.exec!("mkdir .ssh && ssh-keygen -f .ssh/id_rsa -N '' -q && cp .ssh/id_rsa.pub .ssh/authorized_keys")
        Net::SCP.start host, DEFAULT_IDENTITY, :password => @initial_password do |scp|
          scp.download! '~/.ssh/id_rsa', @keys.first
          `chmod 600 #{@keys.first}`
        end
        log_to :file, ssh.exec!("echo ubuntu | sudo -S sh -c 'echo ubuntu  ALL=\\(ALL\\) NOPASSWD:ALL >> /etc/sudoers'")
      end
    end

    AUTH_KEYS = '/root/.ssh/authorized_keys'
    # Copy authorized_keys so root login enabled (backs up authorized_keys if it exists)
    def enable_root_login
      6.times do
        begin
          log_to :file, "Attempt to enable root login with #{DEFAULT_IDENTITY}@#{host} using key #{@keys.inspect}"
          Net::SSH.start host, DEFAULT_IDENTITY, :keys => @keys do |ssh|
            log_to :file, ssh.exec!("sudo sh -c 'test -f #{AUTH_KEYS} && mv #{AUTH_KEYS} #{AUTH_KEYS}.orig || mkdir /root/.ssh'")
            log_to :file, ssh.exec!("sudo sh -c 'cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/'")
          end
          break
        rescue
          sleep 10
          puts 'retrying...'
        end
      end
    end

    # Removed authorized_keys so root login disabled (restores original authorized_keys if it exists)
    def disable_root_login
      Net::SSH.start host, 'root', :keys => @keys do |ssh|
        log_to :file, ssh.exec!("rm #{AUTH_KEYS}")
        log_to :file, ssh.exec!("test -f #{AUTH_KEYS}.orig && mv #{AUTH_KEYS}.orig #{AUTH_KEYS}")
      end
    end
  end
end

