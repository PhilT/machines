# Machines allows simple configuration of development, staging and production computers or images for ec2
require 'active_support'
require 'app_conf'
require 'date'
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

$conf = AppConf.new
$conf.application_dir = File.dirname(__FILE__)

require 'machines/logger'
require 'machines/named_buffer'
require 'machines/app_settings'
require 'machines/command'
require 'machines/log_command'
require 'machines/upload'
require 'machines/core'
require 'machines/commandline'
require 'machines/cloud_machine'
require 'machines/help'

files = Dir[File.join($conf.application_dir, 'machines/commands/*.rb')]
files.sort.each do |file|
  require file
end
