module Machines
  module Commandline
    def start(command)
      command ||= :help
      send(command)
    end

    def method_missing(method, *args, &block)
      help
    end

    def help
      say <<-HELP
machines COMMAND
COMMAND can be:
  htpasswd - Asks for a username and password and generates basic auth in webserver/conf/htpasswd
  generate - Generates an example machines project
  check    - Checks Machinesfile for syntax issues
  test     - Runs through Machinesfile logging all commands to log/output.log but does not acutally run them
  build    - Asks some questions then builds your chosen machine
HELP
    end

    def enter_password(message = 'Enter a password: ')
      begin
        password = ask(message) { |q| q.echo = false }
        password_confirmation = ask('Confirm the password: ') { |q| q.echo = false }
        say "Passwords do not match please re-enter" unless password == password_confirmation
      end while password != password_confirmation
      password
    end


    def htpasswd(username, password)
      conf_dir = File.join(AppConf.webserver, 'conf')
      path = File.join(conf_dir, 'htpasswd')
      say "Generate BasicAuth password and add to #{path}"
      username = ask('Username: ')
      password = enter_password

      require 'webrick/utils'
      crypted_pass.crypt(WEBrick::Utils.random_string(2))
      FileUtils.mkdir conf_dir unless File.exist?(dir)
      File.open(path, 'a') {|file| file.puts "#{username}:#{crypted_pass}" }
      say "Password encrypted and added to #{path}"
    end

    def generate
      FileUtils.cp_r(File.join(AppConf.template_path, '.'), '.')
    end

    def test
      Machines::Base.new.test
    end

    def build
      Machines::Base.setup
    end

  end
end

