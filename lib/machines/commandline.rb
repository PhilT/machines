module Machines
  module Commandline
    def start(command, option)
      if %w(htpasswd new check dryrun build).include?(command)
        AppConf.action = command
        if command == 'new'
          send 'generate', option
        else
          send command
        end
      else
        help
      end
    end

    def help
      say <<-HELP
machines COMMAND
COMMAND can be:
  htpasswd  - Asks for a username and password and generates basic auth in webserver/conf/htpasswd
  new [DIR] - Generates an example machines project. Specify DIR to generate in directory
  check     - Checks Machinesfile for syntax issues
  dryrun    - Runs through Machinesfile logging all commands to log/output.log but does not acutally run them
  build     - Asks some questions then builds your chosen machine
HELP
    end

    def enter_and_confirm_password(message = 'Enter a new password: ')
      begin
        password = ask(message) { |question| question.echo = false }
        password_confirmation = ask('Confirm the password: ') { |question| question.echo = false }
        say "Passwords do not match, please re-enter" unless password == password_confirmation
      end while password != password_confirmation
      password
    end

    def htpasswd
      conf_dir = File.join(AppConf.project_dir, AppConf.webserver, 'conf')
      path = File.join(conf_dir, 'htpasswd')
      say "Generate BasicAuth password and add to #{path}"
      username = ask('Username: ')
      password = enter_and_confirm_password

      crypted_pass = password.crypt(WEBrick::Utils.random_string(2))
      FileUtils.mkdir_p conf_dir
      File.open(path, 'a') {|file| file.puts "#{username}:#{crypted_pass}" }
      say "Password encrypted and added to #{path}"
    end

    def generate dir
      AppConf.project_dir = File.join(AppConf.project_dir, dir) if dir
      FileUtils.cp_r(File.join(AppConf.application_dir, 'template'), AppConf.project_dir)
    end
  end
end

