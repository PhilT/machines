module Machines
  module Questions
    def choose_machine
      machines = File.read(File.join(AppConf.project_dir, 'Machinesfile')).scan(/^machine '(.*?)'/).flatten
      choose(*machines) { |menu| menu.prompt = 'Select machine to build: ' }
    end

    def start_ec2_instance?
      agree 'Would you like to start a new EC2 instance (y/n)? '
    end

    def enter_target_address(type)
      ask "Enter the IP or DNS address of the target #{type} (EC2, VM or LAN address): "
    end

    def choose_user
      choose(*AppConf.users) { |menu| menu.prompt = 'Select a user: ' }
    end

    def enter_password(type, confirm = true)
      begin
        password = ask("Enter #{type} password: ") { |question| question.echo = false }
        break unless confirm
        password_confirmation = ask('Confirm the password: ') { |question| question.echo = false }
        say "Passwords do not match, please re-enter" unless password == password_confirmation
      end while password != password_confirmation
      AppConf.passwords << password if AppConf.passwords && password.size > 4
      password
    end

    def enter_hostname
      ask 'Hostname to set machine to (Shown on bash prompt if default .bashrc used): '
    end
  end
end

