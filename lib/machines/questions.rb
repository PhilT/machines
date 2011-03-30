module Machines
  module Questions
    def choose_machine
      machines = File.read(File.join(AppConf.project_dir, 'Machinesfile')).scan(/^machine '(.*?)'/).flatten
      AppConf.machine = choose(*machines) { |menu| menu.prompt = 'Select machine to build:' }
    end

    def start_ec2_instance?
      AppConf.ec2_instance = agree 'Would you like to start a new EC2 instance (y/n)? '
    end

    def enter_target_address
      AppConf.target_address = ask 'Enter the IP or DNS address of the target machine (EC2, VM, LAN): '
    end

    def choose_user
      users = AppConf.users.keys
      AppConf.user.name = choose(*users) { |menu| menu.prompt = 'Select a user: ' }
    end

    def enter_password
      AppConf.user.pass = enter_and_confirm_password('Enter users password: ')
    end

    def enter_hostname
      AppConf.hostname = ask 'Hostname to set machine to (Shown on bash prompt if default .bashrc used): '
    end
  end
end

