module Machines
  module Commandline
    def execute(command, option)
      help = Help.new
      if help.commands.include?(command)
        AppConf.action = command
        command = 'generate' if command == 'new'
        if option
          send command, option
        else
          send command
        end
      else
        say help.to_s
      end
    end

    def enter_and_confirm_password(message = 'Enter a new password: ')
      begin
        password = ask(message) { |question| question.echo = false }
        password_confirmation = ask('Confirm the password: ') { |question| question.echo = false }
        say "Passwords do not match, please re-enter" unless password == password_confirmation
      end while password != password_confirmation
      password
    end

    def htpasswd ignored = nil
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
      return say 'Directory already exists' if File.exists? AppConf.project_dir
      FileUtils.cp_r(File.join(AppConf.application_dir, 'template'), AppConf.project_dir)
      say "Project created at #{AppConf.project_dir}"
    end

    def packages
      say 'Default packages'
      Dir[File.join(AppConf.application_dir, 'packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
      say ''

      say 'Project packages'
      Dir[File.join(AppConf.project_dir, 'packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
    end

    def override package
      destination = File.join(AppConf.project_dir, 'packages', "#{package}.rb")
      answer = File.exists?(destination) ? ask('Package already exists. Overwrite? (y/n)') : 'y'
      if answer == 'y'
        FileUtils.cp(File.join(AppConf.application_dir, 'packages', "#{package}.rb"), destination)
        say "Package copied to #{destination}"
      else
        say 'Aborted.'
      end
    end
  end
end

