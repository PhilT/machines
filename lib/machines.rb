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
      include eval(ActiveSupport::Inflector.camelize(File.basename(lib, '.rb')))
    end

    def build
      load File.join(AppConf.project_dir, 'Machinesfile')
      Net::SSH.start AppConf.target_address, AppConf.user.name, :password => AppConf.user.pass do |ssh|
        log_output ssh.exec!(command)
      end
    rescue LoadError => e
      raise LoadError, "Machinesfile does not exist. Use `machines generate` to create a template." if e.message =~ /Machinesfile/
      raise
    end

  private
    def upload local_source, remote_dest
      Net::SCP.start AppConf.target_address, AppConf.user.name, :password => AppConf.user.pass do |scp|
        scp.upload! local_source, remote_dest
      end
    rescue
      log_output "UPLOAD FAILED", :red
    end


    def run command
      command
    end

=begin
  private
    def load_machinesfile
      machinesfile = File.join(AppConf.project_dir, 'Machinesfile')
      if File.exists?(machinesfile)
        load File.join(AppConf.project_dir, 'Machinesfile')
      else
        raise LoadError, "Machinesfile does not exist. Use `machines generate` to create a template."
      end
    end

    # Loops through all commands calling with either Net::SSH::exec! or Net::SCP::upload!
    # @param [Optional #exec!] ssh Net::SSH connection to send the commands to. Only output them if ssh is nil
    def run_commands net_ssh = nil
      AppConf.commands.each do |line, command, check|
        log_output "Machinesfile line #{line}:", :blue
        prefix = command.is_a?(Array) ? 'Upload' : 'Run'
        log_output "#{prefix} #{display(command)}", :yellow
        if AppConf.action == 'build'
          if command.is_a?(Array)
            begin
              Net::SCP.start @host, 'root', :keys => @keys do |scp|
                scp.upload! command[0], command[1]
              end
            rescue
              log_output "UPLOAD FAILED", :red
            end
          else
            log_output net_ssh.exec!(command)
          end
          result = check_result net_ssh.exec!(check)
          log_result result
          log_progress line, command, uploaded && result != 'CHECK FAILED'
        else
          check ? log_output(display(check), :green) : log_output('no check', :yellow)
        end
      end
    end

    # Creates a keypair on a dev machine and allows sudo without password
    # to lineup with Ubuntu EC2 images and run the rest of the script
    def setup_dev_machine
      username = AppConf.user.name
      userpass = AppConf.user.pass
      @keys = ["#{host}.key"]
      Net::SSH.start host, username, :password => userpass do |ssh|
        log_to :file, ssh.exec!("mkdir .ssh && ssh-keygen -f .ssh/id_rsa -N '' -q && cp .ssh/id_rsa.pub .ssh/authorized_keys")
        Net::SCP.start host, username, :password => userpass do |scp|
          scp.download! "/home/#{username}/.ssh/id_rsa", @keys.first
          `chmod 600 #{@keys.first}`
        end
        log_to :file, ssh.exec!("echo #{userpass} | sudo -S sh -c 'echo ubuntu  ALL=\\(ALL\\) NOPASSWD:ALL >> /etc/sudoers'")
      end
    end

    AUTH_KEYS = '/root/.ssh/authorized_keys'

    # Copy authorized_keys so root login enabled (backs up authorized_keys if it exists)
    def enable_root_login
      username = AppConf.user.name
      given_up = true
      6.times do
        begin

          log_to :file, "Attempt to enable root login with #{username}@#{host} using key #{@keys.inspect}"
          Net::SSH.start host, username, :keys => @keys do |ssh|
            log_to :file, ssh.exec!("sudo sh -c 'test -f #{AUTH_KEYS} && mv #{AUTH_KEYS} #{AUTH_KEYS}.orig || mkdir /root/.ssh'")
            log_to :file, ssh.exec!("sudo sh -c 'cp /home/#{username}/.ssh/authorized_keys /root/.ssh/'")
          end
          given_up = false
          break
        rescue
          sleep 10
          print '.'
        end
      end
      puts ''
      raise "Timeout connecting to #{host}" if given_up
    end

    # Removed authorized_keys so root login disabled (restores original authorized_keys if it exists)
    def disable_root_login
      Net::SSH.start host, 'root', :keys => @keys do |ssh|
        log_to :file, ssh.exec!("rm #{AUTH_KEYS}")
        log_to :file, ssh.exec!("test -f #{AUTH_KEYS}.orig && mv #{AUTH_KEYS}.orig #{AUTH_KEYS}")
      end
    end
=end
  end
end

