Dir['machines/**/*.rb'].sort.each { |lib| require lib }

require 'net/ssh'
require 'net/scp'
require 'yaml'

@passwords = YAML::load(File.open 'passwords.yml')['passwords']
config = YAML::load(File.open 'machines.yml')[CONFIG]
if config.nil?
  puts "ERROR: #{SERVER} not in machines.yml"
  exit 1
else
  @role = config['role']
  @apps = config['apps']
end
@commands = []
DEFAULT_IDENTITY = 'ubuntu'
TEMP_PASSWORD = 'ubuntu'
TEMP_PASSWORD_ENCRYPTED = "tvXbD6sWjb4mE"

@users = Dir['users/*'].map{|file| File.basename file}

def boot
  if TEST
    run_commands
  else
    enable_root_login
    Net::SSH.start HOST, 'root', :password => TEMP_PASSWORD do |ssh|
      run_commands
    end
    disable_root_login
  end
end

def run_commands
  @commands.each do |name, command|
    puts "MISSING name or command in: [#{name}, #{display(command)}]" unless name && command
    puts "%-15s %s" % [name, display(command)]
    unless TEST
      if command.is_a?(Array)
        Net::SCP.start HOST, 'root', :password => TEMP_PASSWORD do |scp|
          scp.upload! command[0], command[1]
        end
      else
        ssh.exec! command
      end
    end
  end
end

# sets a root password so ssh can login and removes password from existing user account
def enable_root_login
  Net::SSH.start HOST, DEFAULT_IDENTITY, :password => DEFAULT_IDENTITY do |ssh|
    exec! "passwd #{DEFAULT_IDENTITY} -d"
    exec! "echo #{DEFAULT_IDENTITY} | sudo -S usermod -p #{TEMP_PASSWORD_ENCRYPTED} root"
  end
end

# disables root login from SSH by removing the root password
def disable_root_login
  Net::SSH.start HOST, 'root', :password => TEMP_PASSWORD do |ssh|
    exec! "passwd -d root"
  end
end

def display command
  command.to_a.join(' ').gsub("\n", "\\n").gsub(/(#{(@passwords.values << SQL_REPL_PASSWORD << SQL_TEMP_PASSWORD).join('|')})/, "***")
end

def add command
  @commands << [caller[0][/`([^']*)'/, 1], command]
end

