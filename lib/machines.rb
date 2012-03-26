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
  end
end

