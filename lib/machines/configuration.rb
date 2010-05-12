# Configuration Helpers

# Add some text to the end of a file
# File is specified with <tt>options[:to]</tt>
def append line, options = {}
  add "echo '#{line}' >> #{options[:to]}"
end

# Export key/value pairs and optionally write to a file
# _options_ is a hash of key/values if one of them has a key <tt>:to</tt> it's used to append the exports to the file specified.
# e.g. This exports all keys (except :to) and appends them to <tt>~/.bashrc</tt>
#   export RAILS_ENV => 'development', TOOLS_HOME => '~/bin', :to => '~/.bashrc'
def export options
  commands = []
  options.each do |key, value|
    unless key == :to
      command = "export #{key}=#{value}"
      commands << command
      commands << "echo '#{command}' >> #{options[:to]}" if options[:to]
    end
  end
  add commands.join(' && ')
end

# Add a new user (uses a lowlevel add so doesn't set a password. Used to handle authorized_keys files)
def add_user login
  add "useradd #{login}"
end

# Removes a user, home and any other related files
def del_user login
  add "deluser #{login} --remove-all-files"
end

