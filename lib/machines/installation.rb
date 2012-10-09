module Machines
  module Installation
    include FileOperations

    APTGET_QUIET = 'apt-get -q -y'

    # Adds a PPA source and updates apt
    # @param [String] name Name of the PPA
    # @param [String] key_name What to check in apt-key list to ensure it installed
    #     add_ppa 'mozillateam/firefox-stable', 'mozilla'
    def add_ppa name, key_name
      [
        Command.new("add-apt-repository ppa:#{name}", "apt-key list | grep -i #{key_name} #{echo_result}"),
        update
      ]
    end

    # Adds a DEB source
    # @param [String] source URL of the package. If `YOUR_UBUNTU_VERSION_HERE` is included then it
    #                 is replaced by the Ubuntu version name
    # @param [Hash] options
    # @option options [String] :key URL of key
    # @option options [String] :name Used to check `apt-key list` to ensure it installed
    #     sudo deb 'http://dl.google.com/linux/deb/ stable main',
    #       :key => 'https://dl-ssl.google.com/linux/linux_signing_key.pub',
    #       :name => 'Google'
    def deb source, options
      command = "echo deb #{source} >> /etc/apt/sources.list"
      if source =~ /YOUR_UBUNTU_VERSION_HERE/
        command = "expr substr `cat /etc/lsb-release | grep DISTRIB_CODENAME` 18 20 | xargs -I YOUR_UBUNTU_VERSION_HERE #{command}"
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

    # Download, extract, and remove an archive. Currently supports `zip`, `tar.gz`, `tar.bz2`.
    # @param [String] package Package name to extract
    # @param [Hash] options
    # @option options [Optional String] :to folder to clone or extract to (defaults to /usr/local/src)
    def extract package, options = {}
      name = File.basename(package)
      if package[/.zip/]
        cmd = 'unzip -qq'
      elsif package[/.tar.gz/]
        cmd = 'tar -zxf'
      elsif package[/.tar.bz2/]
        cmd = 'tar -jxf'
      else
        raise "extract: Unknown extension for #{package}"
      end
      dir = cmd =~ /unzip/ ? File.basename(name, '.zip') : File.basename(name).gsub(/\.tar.*/, '')
      dest = options[:to] || '/usr/local/src'
      Command.new("cd #{dest} && wget #{package} && #{cmd} #{name} && rm #{name} && cd -", check_dir("#{File.join(dest, dir)}"))
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

    # Clone (or update) a project from a Git repository
    # @param [String] url URL to clone
    # @param [Hash] options
    # @option options [Optional String] :to Folder to clone to
    # @option options [Optional String] :tag Checkout this tag after cloning (requires :to)
    # @option options [Optional String] :branch Switch this branch when cloning
    def git_clone url, options = {}
      raise ArgumentError.new('git_clone Must include a url and folder') if url.nil? || url.empty?
      raise ArgumentError.new('specifying :tag also requires :to') if options[:tag] && options[:to].nil?
      branch = "--branch #{options[:branch]} " if options[:branch]
      dir = options[:to] || url.gsub(/^.*\/|.git/, '')
      command = "test -d #{dir} && (cd #{dir} && git pull) || git clone --quiet #{branch}#{url}"
      command << " #{options[:to]}" if options[:to]
      command = Command.new(command, check_dir(options[:to]))
      command = [command, Command.new("cd #{options[:to]} && git checkout #{options[:tag]}", "git name-rev --name-only HEAD | grep #{options[:tag]}")] if options[:tag]
      command
    end

    # Installs one or more packages using apt, deb or git clone and install.sh (Ignores architecture differences)
    # (See `extract` to just uncompress tar.gz or zip files)
    # @param [Symbol, String, Array] packages can be:
    #   URL::
    #     Download from URL and run `dpkg` (if `:as => :dpkg`)
    #     Download URL to `/usr/local/lib` and link `:bin` to `/usr/local/bin`
    #   Array or string (with no URL)::
    #     Run `apt` to install specified packages in the array or string
    #       Packages are installed separately to aid progress feedback
    #       Ensure this is the main package as dpkg get-selections is used to validate installation
    #     install %w(build-essential libssl-dev mysql-server) #=> Installs apt packages
    #     install 'http://example.com/my_package.deb', :cleanup => true #=> Installs a deb using dpkg then removes the deb
    # @param [Hash] options
    # @option options [Optional Symbol] :as Identify the package type so appropriate command can run. Currently supports `:dpkg` only
    # @option options [Optional String] :bin Specify the bin file to link to (e.g. '/bin/executable' will create a link /usr/local/bin/executable that points to /usr/local/lib/bin/executable)
    def install packages, options = {}
      if packages.is_a?(String)
        if packages =~ /^http:\/\//
          commands = []
          if packages =~ /\.deb$/i
            name = File.basename(packages)
            commands << Command.new("cd /tmp && wget #{packages} && dpkg -i --force-architecture #{name} && rm #{name} && cd -", nil)
          elsif options[:as] == :dpkg
            commands << extract(packages, :to => '/tmp')
            name = File.basename(packages).gsub(/\.(tar|zip).*/, '')
            commands << Command.new("cd /tmp/#{name} && dpkg -i --force-architecture *.deb && cd - && rm -rf /tmp/#{name}", nil)
          elsif options[:bin]
            commands << extract(packages, :to => '/tmp')
            name = File.basename(packages).gsub(/\.(tar|zip).*/, '')
            commands << rename("/tmp/#{name}", "/usr/local/lib")
            commands << link("/usr/local/lib/#{name}/#{options[:bin]}", "/usr/local/bin/#{File.basename(options[:bin])}")
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
        Command.new("#{APTGET_QUIET} purge #{package}", check_package(package, false))
      end
    end

    def update
      Command.new("#{APTGET_QUIET} update > /tmp/apt-update.log", check_string('Reading package lists', '/tmp/apt-update.log'))
    end

    # Update, upgrade, autoremove, autoclean apt packages
    # TODO: Check that check_command really checks the correct command with 'echo $?'
    def upgrade
      %w(update upgrade autoremove autoclean).map do |command|
        Command.new("#{APTGET_QUIET} #{command}", check_command('echo $?', '0'))
      end
    end
  end
end

