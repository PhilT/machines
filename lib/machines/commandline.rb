module Machines
  module Commandline
    def execute(options)
      help = Help.new
      action = options.shift
      if help.actions.include?(action)
        action = 'generate' if action == 'new'
        send action, options
      else
        say help.to_s
      end
    end

    def help options
      say Help.detailed
    end

    def htpasswd options
      path = File.join(AppConf.webserver, 'conf', 'htpasswd')
      say "Generate BasicAuth password and add to #{path}"
      username = ask('Username: ')
      password = enter_password 'users'

      crypted_pass = password.crypt(WEBrick::Utils.random_string(2))
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'a') {|file| file.puts "#{username}:#{crypted_pass}" }
      say "Password encrypted and added to #{path}"
    end

    def generate options
      dir = options.first || '.'
      if File.exists? dir
        confirm = ask 'Folder already exists. Overwrite (y/n)? '
        return unless confirm.downcase == 'y'
      end
      FileUtils.cp_r(File.join(AppConf.application_dir, 'template', '/.'), dir)
      FileUtils.mkdir_p(File.join(dir, 'packages'))
      say "Project created at #{dir}/"
    end

    def packages
      say 'Default packages'
      Dir[File.join(AppConf.application_dir, 'packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
      say ''

      say 'Project packages'
      Dir[File.join('packages', '**/*.rb')].each do |package|
        say " * #{File.basename(package, '.rb')}"
      end
    end

    def override package
      destination = File.join('packages', "#{package}.rb")
      answer = File.exists?(destination) ? ask('Project package already exists. Overwrite? (y/n)') : 'y'
      if answer == 'y'
        FileUtils.cp(File.join(AppConf.application_dir, 'packages', "#{package}.rb"), destination)
        say "Package copied to #{destination}"
      else
        say 'Aborted.'
      end
    end
  end
end

