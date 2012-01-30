# Machines allows simple configuration of development, staging and production computers or images for ec2
require 'active_support'
require 'app_conf'
require 'erb'
require 'fileutils'
require 'highline/import'
require 'net/ssh'
require 'net/scp'
require 'ostruct'
require 'json'
require 'tempfile'
require 'webrick/utils'
require 'yaml'

AppConf.application_dir = File.dirname(__FILE__)

module Machines
  class Base
    Dir[File.join(AppConf.application_dir, 'machines/**/*.rb')].sort.each do |lib|
      require lib
      path = ActiveSupport::Inflector.camelize(File.basename(lib, '.rb'))
      module_or_class = eval(path, nil, "eval: #{path}")
      include module_or_class unless module_or_class.is_a?(Class)
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

    def tasks
      AppConf.log_only = true
      init
      load_machinesfile
      say 'Tasks'
      AppConf.tasks.each do |task_name, settings|
        say "  %-20s #{settings[:description]}" % task_name
      end
    end

    def dryrun options
      AppConf.log_only = true
      build options
    end

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

    def prepare_to_exit
      exit if $exit_requested
      $exit_requested = true
      Command.console.log("\nEXITING after current command completes...", :color => :warning)
      Command.console.log("(Press again to terminate immediately)...", :color => :warning)
    end
  end
end

