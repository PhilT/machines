# Upload a file using SCP
# options:
# :perms => chmod::  if specified chmods the file
# :owner => user::   if specified chowns the file
def upload local_source, remote_dest
  add [local_source, remote_dest]
  chmod options[:perms], dir if options[:perms]
  chown options[:owner], dir if options[:owner]
end

# Rename remote file from _oldname_ to _newname_
def rename oldname, newname
  add "mv #{oldname} #{newname}"
end

def remove_version_info name
  add "find . -maxdepth 1 -name '#{name}*' -a -type d | xargs -I xxx mv xxx #{name}"
end

def copy from, to
  add "cp #{from} #{to}"
end

def link from, options
  add "ln -sf #{options[:to]} #{from}"
end

def replace regex, options
  add "sed -i 's/#{regex}/#{options[:with]}/' #{options[:in]}"
end

# Create a folder on the remote host
# options:
# :perms => chmod::  if specified chmods the folder
# :owner => user::   if specified chowns the folder
def mkdir dir, options
  add "mkdir -p #{dir}"
  chmod options[:perms], dir if options[:perms]
  chown options[:owner], dir if options[:owner]
end

def chmod mod, dir
  add "chmod #{mod} #{dir}"
end

def chown user, dir
  add "chown #{user}:#{user} #{dir}"
end

def make_app_folder_structure where
  %w(releases shared/config shared/system).each do |dir|
    mkdir dir, :owner => DEFAULT_IDENTITY
  end
end

