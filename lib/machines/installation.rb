module Machines
  module Installation
    APTGET_QUIET = 'apt-get -q -y'

    # Adds a DEB source
    # @param [String] source URL of the package. If DISTRIB_CODENAME is included then it
    #                 is replaced by the Ubuntu version name
    # @param [Hash] options
    # @option options [String] :key URL of key
    # @option options [String] :name Used to check `apt-key list` to ensure it installed
    #     sudo deb 'http://dl.google.com/linux/deb/ stable main',
    #       :key => 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
    #       :name => 'Google'
    def deb source, options
      command = "echo deb #{source} >> /etc/apt/sources.list"
      if source =~ /DISTRIB_CODENAME/
        command = "expr substr `cat /etc/lsb-release | grep DISTRIB_CODENAME` 18 20 | xargs -I DISTRIB_CODENAME #{command}"
      end
      [
        Command.new(command, check_string(source.gsub(/ .*$/, ''), '/etc/apt/sources.list')),
        Command.new("wget -q #{options[:key]} -O - | apt-key add -", "apt-key list | grep -i #{options[:name]} #{echo_result}"),
        update
      ]
    end

    # Preseed debconf to allow silent installs
    # @param [String] app Name of application to configure
    # @param [String] setting The setting to set
    # @param [String] type Data type of the value
    # @param value The value to set (Ruby types supported)
    def debconf app, setting, type, value
      command = "echo #{app} #{setting} #{type} #{value} | debconf-set-selections"
      check = "debconf-get-selections | grep #{app} #{echo_result}"
      Command.new(command, check)
    end

    # Adds a PPA source
    # @param [String] user The user of the PPA
    # @param [String] name Name of the PPA
    # @param [String] key_name What to check in apt-key list to ensure it installed
    #     add_ppa 'mozillateam/firefox-stable', 'mozilla'
    def add_ppa name, key_name
      [
        Command.new("add-apt-repository ppa:#{name}", "apt-key list | grep -i #{key_name} #{echo_result}"),
        update
      ]
    end

    def update
      Command.new("#{APTGET_QUIET} update", nil)
    end

    # Update, upgrade, autoremove, autoclean apt packages
    def upgrade
      %w(update upgrade autoremove autoclean).map do |command|
        Command.new("#{APTGET_QUIET} #{command}", nil)
      end
    end

    # Installs one or more packages using apt, deb or git clone and install.sh (Ignores architecture differences)
    # (See `extract` to just uncompress tar.gz or zip files)
    # @param [Symbol, String, Array] packages can be:
    #   Git URL::
    #     Git clone URL and run `./install.sh` (or ./install)
    #   URL::
    #     Download from the specified URL and run `dpkg`
    #   Array or string (with no URL)::
    #     Run `apt` to install specified packages in the array or string
    #       Packages are installed separately to aid progress feedback
    #       Ensure this is the main package as dpkg get-selections is used to validate installation
    # @param [Hash] options
    # @option options [String] :to Switch to specified directory to install. Used by Git installer
    # @option options [String] :options Add extra options to `./install.sh`
    #     install 'git://github.com/gmate/gmate.git', :to => dir, :args => '-n' #=> git clones and runs install with -n
    #     install %w(build-essential libssl-dev mysql-server) #=> Installs apt packages
    #     install 'http://example.com/my_package.deb', :cleanup => true #=> Installs a deb using dpkg then removes the deb
    def install packages, options = {}
      if packages.is_a?(String)
        if packages.scan(/^git/).any?
          required_options options, [:to]
          command = "rm -rf #{options[:to]} && " +
            "git clone #{packages} #{options[:to]} && " +
            "cd #{options[:to]} && " +
            "find . -maxdepth 1 -name install* | xargs -I xxx bash xxx #{options[:args]}"
          check = "find #{options[:to]} -maxdepth 1 -name install* | grep install #{echo_result}"
          commands = Command.new(command, check)
        elsif packages.scan(/^http:\/\//).any?
          commands = []
          if packages.scan(/\.deb$/i).empty?
            commands << extract(packages)
            name = File.basename(packages).gsub(/\.(tar|zip).*/, '')
            commands << Command.new("cd /tmp/#{name} && dpkg -i --force-architecture *.deb && cd - && rm -rf /tmp/#{name}", nil)
          else
            name = File.basename(packages)
            commands << Command.new("cd /tmp && wget #{packages} && dpkg -i --force-architecture #{name} && rm #{name} && cd -", nil)
          end
          return commands
        else
          packages = [packages]
        end
      end

      if packages.is_a?(Array)
        commands = packages.map do |package|
          Command.new("#{APTGET_QUIET} install #{package}", check_package(package))
        end
      end
      commands
    end

    # Remove one or more packages
    # @param [Array] packages Packages to remove
    def uninstall packages
      packages.map do |package|
        Command.new("#{APTGET_QUIET} remove #{package}", check_package(package, false))
      end
    end

    # Install a gem
    # @param [String] package Name of the gem
    # @param [Hash] options
    # @option options [String] :version Optional version number
    def gem package, options = {}
      version =  " -v \"#{options[:version]}\"" if options[:version]
      Command.new("gem install #{package}#{version}", check_gem(package, options[:version]))
    end

    # Update gems
    # @example Update Rubygems
    #     gem_update '--system'
    def gem_update options = ''
      Command.new("gem update #{options}", nil)
    end

    # Download, extract, and remove an archive. Currently supports `zip` or `tar.gz`. Extracts into /tmp
    # @param [String] package Package name to extract
    # @param [Hash] options
    # @option options [Optional String] :to directory to clone to
    def extract package, options = {}
      name = File.basename(package)
      cmd = package[/.zip/] ? 'unzip -qq' : 'tar -zxf'
      dir = cmd =~ /unzip/ ? File.basename(name, '.zip') : File.basename(name).gsub(/\.tar.*/, '')
      dest = " mv #{dir} #{options[:to]} &&" if options[:to]
      Command.new("cd /tmp && wget #{package} && #{cmd} #{name} &&#{dest} rm #{name} && cd -", check_dir("#{options[:to] || File.join('/tmp', dir)}"))
    end

    # Clone a project from a Git repository
    # @param [String] url URL to clone
    # @param [Hash] options
    # @option options [Optional String] :to directory to clone to
    def git_clone url, options = {}
      Command.new("git clone -q #{url} #{options[:to]}", check_dir(options[:to]))
    end
  end
end

