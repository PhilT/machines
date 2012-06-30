module Machines
  module FileOperations
    # Add a line of text to the end of a file unless it already exists
    # @param [String] text Text to add
    # @param [Hash] options
    # @option options [String] :to File to append to
    def append text, options
      text = text.gsub(/([\\$"`])/, '\\\\\1')
      Command.new("grep \"#{text}\" #{options[:to]} || echo \"#{text}\" >> #{options[:to]}", check_string(text, options[:to]))
    end

    # Change permissions of a path
    # @param [String, Integer] mode chmod permissions to set
    # @param [String] path Path to set
    def chmod mode, path
      Command.new("chmod #{mode} #{path}", check_perms(mode, path))
    end

    # Change ownership of a path
    # @param [String] user Owner to set
    # @param [String] path Path to set
    # @param [Hash] options
    # @option options [String] :recursive Chowns recursively if true
    def chown user, path, options = {}
      recursive = '-R ' if options[:recursive]
      Command.new("chown #{recursive}#{user}:#{user} #{path}", check_owner(user, path))
    end

    # Copy a remote file or folder (will overwrite)
    # @param [String] from Existing path
    # @param [String] to Path to copy to
    def copy from, to
      Command.new("cp -rf #{from} #{to}", check_file(to))
    end

    # Write a file from an ERB template
    # @param [String] erb_path Path to the ERB file to process
    # @param [Hash] options
    # @option options [AppBuilder] :settings Contains the settings as OpenStruct method calls for calling from the template
    # @option options [String] :to File to write to
    def create_from erb_path, options
      erb = ERB.new(File.read(erb_path), nil, '<>')
      binding = options[:settings] ? options[:settings].get_binding : nil
      options[:name] = erb_path
      write erb.result(binding), options
    end

    # Add a symlink
    # @param [String] target Existing path to link
    # @param [String] link_name path name for the link
    def link target, link_name
      Command.new("ln -sf #{target} #{link_name}", check_link(link_name))
    end

    # Create a path or paths on the remote host (Uses -p to be safe and create full path)
    # @param [String, Array] dirs A single path, multiple paths or array of paths to create
    def mkdir *dirs
      dirs.flatten.map do |dir|
        Command.new("mkdir -p #{dir}", check_dir(dir))
      end
    end

    # Rename a remote file or folder
    # @param [String] oldname Existing filename
    # @param [String] newname Rename to this =
    def rename oldname, newname
      Command.new("mv -f #{oldname} #{newname}", check_file(newname))
    end

    # Remove a remote file or folder
    # @param [String] file or folder to remove (uses rm with -rf which ignores non-existent files and is recursive)
    def remove file
      Command.new("rm -rf #{file}", check_file(file, false))
    end

    # Take off the version numbers from a path name
    # @param [String] name Name of the path to rename
    def remove_version_info name
      Command.new("find . -maxdepth 1 -name \"#{name}*\" -a -type d | xargs -I xxx mv xxx #{name}", check_file(name))
    end

    # Replace some text in a file
    # @param [String] regex The expression to search for
    # @param [Hash] options
    # @option options [String] :with Text to use as the replacement
    # @option options [String] :in Filename to replace text in
    def replace regex, options
      required_options options, [:with, :in]
      with = options[:with].gsub(/([\n\/\\$"`])/, '\\\\\1')
      Command.new("sed -i \"s/#{regex}/#{with}/\" #{options[:in]}", check_string(with, options[:in]))
    end

    # (Over)write a file with the specified content
    # @param [String] text Text to add
    # @param [Hash] options
    # @option options [String] :to File to write to
    # @option options [String] :name Give the buffer a displayable name (e.g. when generated from a template)
    def write text, options
      Upload.new(NamedBuffer.new(options[:name], text), options[:to], check_string(text, options[:to]))
    end
  end
end

