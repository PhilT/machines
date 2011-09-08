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
    Dir[File.join(File.dirname(__FILE__), 'machines/**/*.rb')].sort.each do |lib|
      require lib
      path = ActiveSupport::Inflector.camelize(File.basename(lib, '.rb'))
      module_or_class = eval(path, nil, "eval: #{path}")
      include module_or_class unless module_or_class.is_a?(Class)
    end

    def init
      $exit_requested = false
      AppConf.machines = {}
      AppConf.passwords = []
      AppConf.commands = []
      AppConf.apps = {}
      AppConf.tasks = {}
      AppConf.from_hash(:user => {})
      AppConf.from_hash(:db => {})
      AppConf.load('config/config.yml')

      path = 'output.log'
      FileUtils.mkdir_p File.dirname(path)
      AppConf.file ||= Machines::Logger.new File.open(path, 'w')
      AppConf.console ||= Machines::Logger.new STDOUT, :truncate => true
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

    def dryrun
      AppConf.log_only = true
      build
    end

    # Loads Machinesfile, opens an SCP connection and runs all commands and file uploads
    def build task_name = nil
      AppConf.building = true
      init
      load_machinesfile

      task task_name.to_sym if task_name

      if AppConf.ec2.use
        username = 'ubuntu'
        scp_options = {:keys => [AppConf.ec2.private_key_file]}
      else
        username = AppConf.user.name
        scp_options = {:password => AppConf.user.pass}
      end

      if AppConf.log_only
        AppConf.commands.each do |command|
          command.run
        end
      else
        Kernel.trap("INT") { prepare_to_exit }
        Net::SCP.start AppConf.target_address, username, scp_options do |scp|
          Command.scp = scp
          AppConf.commands.each do |command|
            command.run
            AppConf.file.flush
            exit if $exit_requested
          end
        end
      end
    end

    def prepare_to_exit
      $exit_requested = true
      AppConf.console.log("\nEXITING after current command completes...", :color => :warning)
    end
  end
end

