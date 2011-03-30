module Machines
  module FileOperations
    # Rename a remote file
    # @param [String] oldname Existing filename
    # @param [String] newname Rename to this =
    def rename oldname, newname
      run "mv #{oldname} #{newname}", check_file(newname)
    end

    # Copy a remote file
    # @param [String] from Existing filename
    # @param [String] to Filename to copy to
    def copy from, to
      run "cp #{from} #{to}", check_file(to)
    end

    def remove file, options = {}
      run "rm #{options[:force] ? '-f ' : ''}#{file}", check_file(file, false)
    end

    # Take off the version numbers from a path name
    # @param [String] name Name of the path to rename
    def remove_version_info name
      run "find . -maxdepth 1 -name '#{name}*' -a -type d | xargs -I xxx mv xxx #{name}", check_file(name)
    end

    # Add a symlink
    # @param [String] target Existing path to link
    # @param [String] link_name path name for the link
    def link target, link_name
      run "ln -sf #{target} #{link_name}", check_link(link_name)
    end

    # Replace some text in a file
    # @param [String] regex The expression to search for
    # @param [Hash] options
    # @option options [String] :with Text to use as the replacement
    # @option options [String] :in Filename to replace text in
    def replace regex, options
      required_options options, [:with, :in]
      run "sed -i 's/#{regex}/#{options[:with].to_s.gsub('/', '\/').gsub("\n", "\\n")}/' #{options[:in]}", check_string(options[:with], options[:in])
    end

    # Write an ERB template
    # @param [String] erb_path Path to the ERB file to process
    # @param [Hash] options
    # @option options [String] :to File to write to
    def template erb_path, options
      erb = ERB.new(File.open(erb_path))
      binding = options[:settings] ? options[:settings].get_binding : nil
      write erb.result(binding), options
    end

    # Create a path on the remote host
    def mkdir dir, mode = nil
      run "mkdir -p #{dir}", check_dir(dir)
      chmod mode, dir if mode
    end

    # Change permissions of a path
    # @param [String, Integer] mode chmod permissions to set
    # @param [String] path Path to set
    def chmod mode, path
      run "chmod #{mode} #{path}", check_perms(mode, path)
    end

    # Change ownership of a path
    # @param [String] user Owner to set
    # @param [String] path Path to set
    # @param [Hash] options
    # @option options [String] :recursive Chowns recursively if true
    def chown user, path, options = {}
      recursive = '-R ' if options[:recursive]
      run "chown #{recursive}#{user}:#{user} #{path}", check_owner(user, path)
    end
  end
end

