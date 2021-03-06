module Machines
  module Commands
    # The `Checks` module is used to execute a command to check whether the
    # previous command was successful. These methods are useful when writing
    # your own custom commands.
    module Checks
      def echo_result
        '&& echo CHECK PASSED || echo CHECK FAILED'
      end

      def check_package package, exists = true
        "dpkg --get-selections | grep #{package}.*#{exists ? '' : 'de'}install #{echo_result}"
      end

      def check_gem gem, version = nil
        version = " -v #{version}" if version
        "gem search #{gem}#{version} --installed #{echo_result}"
      end

      def check_file file, exists = true
        "test #{exists ? '' : '! '}-s #{file} #{echo_result}"
      end

      def check_link link
        "test -L #{link} #{echo_result}"
      end

      def check_dir dir, exists = true
        "test #{exists ? '' : '! '}-d #{dir} #{echo_result}"
      end

      def check_perms perms, path
        perms = perms.to_s
        mods = %w(--- --x -w- -wx r-- r-x rw- rwx)
        "ls -la #{path} | grep #{mods[perms[0..0].to_i]}#{mods[perms[1..1].to_i]}#{mods[perms[2..2].to_i]} #{echo_result}"
      end

      def check_owner user, path
        "ls -la #{path} | grep \"#{user}.*#{user}\" #{echo_result}"
      end

      def check_string string, file
        "grep \"#{string}\" #{file} #{echo_result}"
      end

      def check_daemon daemon, exists = true
        command = 'ps aux'
        search_for = "| grep #{daemon}"
        remove_grep = '| grep -v grep'
        negative = "| grep -v #{daemon} " unless exists
        "#{command} #{search_for} #{remove_grep} #{negative}#{echo_result}"
      end

      def check_init_d name
        "test -L /etc/rc0.d/K20#{name} #{echo_result}"
      end

      def check_command command, match = nil
        if match
          "#{command} | grep #{match} #{echo_result}"
        else
          "#{command} #{echo_result}"
        end
      end
    end
  end
end
