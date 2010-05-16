require 'rubygems'
require 'net/ssh'
require 'net/scp'
require 'yaml'
require 'active_support'

Dir[File.join(File.dirname(__FILE__), 'machines/**/*.rb')].sort.each { |lib| require lib }
include Machines::Configuration
include Machines::Database
include Machines::FileOperations
include Machines::Installation
include Machines::Services

# @private
DEFAULT_IDENTITY = 'ubuntu'
# @private
TEMP_PASSWORD = 'ubuntu'
# @private
TEMP_PASSWORD_ENCRYPTED = "tvXbD6sWjb4mE"

def machine name, environment, options = {:apps => [], :role => nil}
  if name == @config_name
    @environment = environment
    @apps = options[:apps]
    @role = options[:role]
  end
end

def development?
  @environment == :development
end

# Set a database password for an application (Used to communicate between application and db server)
def password application, password
  @passwords ||= {}
  @passwords[application] = password
end

# @param [String] config Configuration to use from machines.yml
# @param [String] host
# @param [String] username
# @param [String] machinename Name to give the computer (set in computername)
# @param [String] dbmaster URL to the master database
def configure config_name, host, username, machinename, dbmaster
  @config_name = config_name
  @host = host
  @username = username
  @machinename = machinename
  @dbmaster = dbmaster
end

# Called from `bin/machines` startup script.
# @param [Boolean] test If true just outputs the commands that would be run but does not run them
def start command
  @commands = []
  validate_configuration
  discover_users
  if command == 'test'
    run_commands
  elsif command == 'install'
    enable_root_login
    Net::SSH.start @host, 'root', :password => TEMP_PASSWORD do |ssh|
      run_commands ssh
    end
    disable_root_login
  end
end

def validate_configuration
  if @apps.nil?
    raise ArgumentError, "#{@config_name} does not exist. Check machine configurations in your Machinesfile."
  end
end

def discover_users
  @users = Dir['users/*'].map{|file| File.basename file}
end

# Loops through all commands calling with either Net::SSH::exec! or Net::SCP::upload!
# @param [Optional #exec!] ssh Net::SSH connection to send the commands to. Only output them if ssh is nil
def run_commands net_ssh = nil
  @commands.each do |name, command|
    raise ArgumentError, "MISSING name or command in: [#{name}, #{display(command)}]" unless name && command
    log "%-15s %s" % [name, display(command)]
    if net_ssh
      if command.is_a?(Array)
        Net::SCP.start @host, 'root', :password => TEMP_PASSWORD do |scp|
          scp.upload! command[0], command[1]
        end
      else
        net_ssh.exec! command
      end
    end
  end
end

def log message
  puts message
end

# sets a root password so ssh can login and removes password from existing user account
def enable_root_login
  Net::SSH.start @host, DEFAULT_IDENTITY, :password => DEFAULT_IDENTITY do |ssh|
    ssh.exec! "echo #{DEFAULT_IDENTITY} | sudo -S usermod -p #{TEMP_PASSWORD_ENCRYPTED} root"
    ssh.exec! "passwd #{DEFAULT_IDENTITY} -d"
  end
end

# disables root login from SSH by removing the root password
def disable_root_login
  Net::SSH.start @host, 'root', :password => TEMP_PASSWORD do |ssh|
    ssh.exec! "passwd -d root"
  end
end

# Utility method to tidy up commands before being logged
def display command
  command = command.to_a.join(' ').gsub("\n ", "\\")
  command.gsub!(/(#{(@passwords.values).join('|')})/, "***") if @passwords.values.any?
  command
end

def required_options options, required
  required.each do |option|
    raise ArgumentError, "Missing #{option}" unless options[option]
  end
end

# Queues up a command on the command list. Includes the calling method name for logging
def add command
  @commands << [caller[0][/`([^']*)'/, 1], command]
end

