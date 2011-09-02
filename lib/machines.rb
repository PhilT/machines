# Machines allows simple configuration of development, staging and production computers or images for ec2
require 'active_support'
require 'app_conf'
require 'AWS'
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

AppConf.project_dir = Dir.pwd
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
      AppConf.machines = {}
      AppConf.passwords = []
      AppConf.commands = []
      AppConf.apps = {}
      AppConf.tasks = {}
      AppConf.from_hash(:user => {})
      AppConf.from_hash(:db => {})
      AppConf.load(File.join(AppConf.project_dir, 'config/config.yml'))

      path = File.join(AppConf.project_dir, 'log', 'output.log')
      FileUtils.mkdir_p File.dirname(path)
      AppConf.file ||= Machines::Logger.new File.open(path, 'w')
      AppConf.console ||= Machines::Logger.new STDOUT, :truncate => true
    end

    def dryrun
      AppConf.log_only = true
      build
    end

    # Loads Machinesfile, opens an SCP connection and runs all commands and file uploads
    def build task_name = nil
      init
      machinesfile = File.join(AppConf.project_dir, 'Machinesfile')
      eval File.read(machinesfile), nil, "eval: #{machinesfile}"

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
        Net::SCP.start AppConf.target_address, username, scp_options do |scp|
          Command.scp = scp
          AppConf.commands.each do |command|
            command.run
          end
        end
      end
    rescue LoadError => e
      if e.message =~ /Machinesfile/
        raise LoadError, "Machinesfile does not exist. Use `machines new <DIR>` to create a template."
      else
        raise
      end
    end
  end
end

