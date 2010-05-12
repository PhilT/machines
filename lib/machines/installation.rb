#Helpers for installation tasks

# Upgrade packages
def update
  add "apt-get update && apt-get upgrade"
end

# Installs one or more packages using apt, deb or it's install.sh file
# _packages_ can be:
# sh::    switches to the folder specified by <tt>options[:in]</tt> and runs <tt>./install.sh</tt>
# array:: uses <tt>apt-get install</tt> to install all the packages in the array
# url::   downloads from the specified url and runs the package installer (currently dpkg)
def install packages, options = {}
  if packages == 'sh'
    command = "cd #{options[:in]} && ./install.sh -y"
  elsif packages.is_a?(String) && packages.scan(/^http/).any?
    name = File.basename(packages)
    command = "wget #{packages} && dpkg -i #{name} && rm #{name}"
  else
    command = "apt-get install -q -y #{packages.join(' ')}"
  end
  add command
end

# Installs a gem with optional <tt>options[:version]</tt>
def gem package, options = {}
  version =  " -v '#{options[:version]}'" if options[:version]
  add "gem install #{package}#{version}"
end

# Currently used to do `gem update --system` but could be expanded
def gem_update options = ''
  add "gem update #{options}"
end

# Downloads, extracts, and removes an archive. Currently supports `zip` or `tar.gz`
def extract package
  name = File.basename(package)
  cmd = package[/.zip/] ? 'unzip' : 'tar -zxvf'
  add "wget #{package} && #{cmd} #{name} && rm #{name}"
end

# Git clone from _url_ to path in <tt>options[:to]</tt>
def git_clone url, options
  add "git clone #{url} #{options[:to]}"
end

# Downloads and extracts nginx source and installs passenger module
# Use: <tt>options[:with] => :ssl</tt> to include ssl module
def install_nginx url, options
  extract url
  flags = "--extra-configure-flags=--with-http_ssl_module" if options[:with].to_sym == :ssl
  name = File.basename(url).gsub(/.tar.gz|.zip/, '')
  add "passenger-install-nginx-module --auto --nginx-source-dir=$HOME/#{name} #{flags} && rm -rf #{name}"
end

