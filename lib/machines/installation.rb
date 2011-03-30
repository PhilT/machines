module Machines
  module Installation
    APTGET_QUIET = 'export DEBIAN_FRONTEND=noninteractive && apt-get -q -y'

    # Adds a DEB source
    # @param [String] name Used to name the sources.list file and what to check in apt-key list to ensure it installed
    # @param [String] source URL of the package
    # @param [Hash] options
    # @option options [String] :to Overrides name of sources.list file
    # @option options [String] :gpg URL of key
    #     add_source 'google', 'http://dl.google.com/linux/deb/ stable main', :gpg => 'https://dl-ssl.google.com/linux/linux_signing_key.pub', :to => 'google-chrome'
    def add_source name, source, options
      append "deb #{source}", :to => "/etc/apt/sources.list.d/#{options[:to] || name}.list"
      run "wget -q -O - #{options[:gpg]} | apt-key add -", "apt-key list | grep -i #{name} #{echo_result}"
    end

    # Adds a PPA source
    # @param [String] user The user of the PPA
    # @param [String] name Name of the PPA
    # @param [String] key_name What to check in apt-key list to ensure it installed
    #     add_ppa 'mozillateam/firefox-stable', 'mozilla'
    def add_ppa name, key_name
      run "add-apt-repository ppa:#{name}", "apt-key list | grep -i #{key_name} #{echo_result}"
    end

    # Update, upgrade, autoremove, autoclean apt packages
    def update
      %w(update upgrade autoremove autoclean).each do |command|
        run "#{APTGET_QUIET} #{command}", nil
      end
    end

    # Installs one or more packages using apt, deb or it's install.sh file
    # @param [Symbol, String, Array] packages can be:
    #   Git URL::
    #     Git clone URL and run `./install.sh`
    #   Array::
    #     Run `apt` to install specified packages in the array (installed separately to aid progress feedback)
    #   URL::
    #     Download from the specified URL and run `dpkg`
    # @param [Hash] options
    # @option options [String] :to Switch to specified directory to install. Used by Git installer
    # @option options [String] :as Run as specified user
    # @option options [String] :options Add extra options to `./install.sh`
    #     install 'git://github.com/wayneeseguin/rvm.git', :to => '/home/ubuntu/installer', :as => 'ubuntu', :options => '--auto' #=> Runs install.sh --auto in /home/ubuntu/installer folder
    #     install %w(build-essential libssl-dev mysql-server) #=> Installs apt packages
    #     install 'http://example.com/my_package.deb', :cleanup => true #=> Installs a deb using dpkg then removes the deb
    def install packages, options = {}
      if packages.is_a?(String)
        if packages.scan(/^git/).any?
          required_options options, [:to]
          commands = ["rm -rf #{options[:to]}",
            "git clone #{packages} #{options[:to]}",
            "cd #{options[:to]}",
            "find . -maxdepth 1 -name install* | xargs -I xxx bash xxx #{options[:args]}"]
          run commands, options.merge(:check => "find #{options[:to]} -maxdepth 1 -name install* | grep install #{echo_result}")
        elsif packages.scan(/^http:\/\//).any?
          name = File.basename(packages)
          run ["cd /tmp", "wget #{packages}", "dpkg -i #{name}", "rm #{name}", "cd -"], nil
        end
      else
        packages.each do |package|
          run "#{APTGET_QUIET} install #{package}", check_package(package)
        end
      end
    end

    # Remove one or more packages
    # @param [Array] packages Packages to remove
    def uninstall packages
      packages.each do |package|
        run "#{APTGET_QUIET} remove #{package}", check_package(package, false)
      end
    end

    # Install a gem
    # @param [String] package Name of the gem
    # @param [Hash] options
    # @option options [String] :version Optional version number
    def gem package, options = {}
      version =  " -v '#{options[:version]}'" if options[:version]
      run ["gem install #{package}#{version}"], options.merge(:check => check_gem(package, options[:version]))
    end

    # Update gems
    # @example Update Rubygems
    #     gem_update '--system'
    def gem_update options = ''
      run "gem update #{options}", nil
    end

    # Download, extract, and remove an archive. Currently supports `zip` or `tar.gz`. Extracts into /tmp
    # @param [String] package Package name to extract
    def extract package
      name = File.basename(package)
      cmd = package[/.zip/] ? 'unzip -qq' : 'tar -zxf'
      dir = cmd =~ /unzip/ ? File.basename(name, '.zip') : File.basename(name, '.tar.gz')
      run "cd /tmp && wget #{package} && #{cmd} #{name} && rm #{name} && cd -", check_dir("/tmp/#{dir}")
    end

    # Clone a project from a Git repository
    # @param [String] url URL to clone
    # @param [Hash] options
    # @option options [Optional String] :to directory to clone to
    def git_clone url, options = {}
      run "git clone -q #{url} #{options[:to]}", check_dir(options[:to])
    end

  end
end

