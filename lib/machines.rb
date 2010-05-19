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
include Machines::Helpers
include Machines::Checks

DEFAULT_IDENTITY = 'ubuntu'
TEMP_PASSWORD = 'ubuntu'
TEMP_PASSWORD_ENCRYPTED = "tvXbD6sWjb4mE"
DEFAULT_USERNAME = 'www'

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
  @passwords[application] = password
end

# Takes the arguments given on the commandline except the <command>. Set defaults.
def configure args
  @commands = []
  @passwords = {}
  @config_name, @host, @password, @dbmaster, @machinename, @username = args
  @dbmaster ||= @host
  @machinename ||= @config_name
  @username ||= DEFAULT_USERNAME
  raise 'Password not set' unless @password
  discover_users
  set_machine_name_and_hosts # TODO: Is this the right place?
end

# Called from `bin/machines` startup script.
# @param [Boolean] test If true just outputs the commands that would be run but does not run them
def start command
  if command == 'test'
    run_commands
  elsif command == 'install'
    prepare_log_file
    enable_root_login
    Net::SSH.start @host, 'root', :password => TEMP_PASSWORD do |ssh|
      create_user ssh
      run_commands ssh
    end
    disable_root_login
  end
end

def discover_users
  @users = Dir['users/*'].map{|file| File.basename file}
end

# Loops through all commands calling with either Net::SSH::exec! or Net::SCP::upload!
# @param [Optional #exec!] ssh Net::SSH connection to send the commands to. Only output them if ssh is nil
def run_commands net_ssh = nil
  count = @commands.size.to_f
  i = 1
  @commands.each do |name, command, check|
    raise ArgumentError, "MISSING name or command in: [#{name}, #{display(command)}]" unless name && command
    progress = i / count * 100
    i += 1
    print "#{"%-4s" % progress.round}% [#{'=' * progress}#{' ' * (100 - progress)}]\r"
    if net_ssh
      log_to :file, "#{name})".yellow
      log_to :file, "Running: #{display(command).yellow}"
      if command.is_a?(Array)
        Net::SCP.start @host, 'root', :password => TEMP_PASSWORD do |scp|
          scp.upload! command[0], command[1]
        end
      else
        log_to :file, net_ssh.exec!(command)
      end
      log_result_to_file check, net_ssh.exec!(check)
    else
      log_to :screen, "#{"%-4s" % (name + ')')} #{display(command)}"
    end
    puts
  end
end

# copy etc/hosts file and set machine name
def set_machine_name_and_hosts
  upload 'etc/hosts', '/etc/hosts' if development? && File.exist?('etc/hosts')
  replace 'ubuntu', :with => @machinename, :in => '/etc/{hosts,hostname}'
end

# Create the user with credentials specified on the commandline
def create_user net_ssh
  password = "-p #{@password} " if @password
  log_to :file, net_ssh.exec!("useradd #{password}-G admin #{@username}")
end

# Set a root password so ssh can login
def enable_root_login
  Net::SSH.start @host, DEFAULT_IDENTITY, :password => DEFAULT_IDENTITY do |ssh|
    log_to :file, ssh.exec!("echo #{DEFAULT_IDENTITY} | sudo -S usermod -p #{TEMP_PASSWORD_ENCRYPTED} root")
  end
end

# Disable root login from SSH by removing the root password
def disable_root_login
  Net::SSH.start @host, 'root', :password => TEMP_PASSWORD do |ssh|
    log_to :file, ssh.exec!("passwd -d root")
  end
end

