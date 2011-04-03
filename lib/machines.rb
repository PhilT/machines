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

AppConf.project_dir = Dir.pwd
AppConf.application_dir = File.dirname(__FILE__)

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

      Net::SCP.start AppConf.target_address, AppConf.user.name, :password => AppConf.user.pass do |scp|
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

