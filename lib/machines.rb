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
require 'tempfile'
require 'webrick/utils'
require 'yaml'

module Machines
  class Base
    Dir[File.join(File.dirname(__FILE__), 'machines/**/*.rb')].sort.each do |lib|
      require lib
      module_or_class = eval(ActiveSupport::Inflector.camelize(File.basename(lib, '.rb')))
      include module_or_class unless module_or_class.is_a?(Class)
    end

    # Loads Machinesfile, opens an SCP connection and runs all commands and file uploads
    def build
      load File.join(AppConf.project_dir, 'Machinesfile')

      if AppConf.ec2_instance
        username = 'ubuntu'
        options = {:keys => [AppConf.ec2.private_key_file]}
      else
        username = AppConf.user.name
        options = {:password => AppConf.user.pass}
      end
      Net::SCP.start AppConf.target_address, username, options do |scp|
        Command.scp = scp
        AppConf.commands.each do |command|
          command.run
        end
      end
    rescue LoadError => e
      if e.message =~ /Machinesfile/
        raise LoadError, "Machinesfile does not exist. Use `machines generate` to create a template."
      else
        raise
      end
    end
  end
end

