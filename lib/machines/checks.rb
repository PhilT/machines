module Machines
  module Checks
    def pass_fail
      '&& echo CHECK PASSED || echo CHECK FAILED'
    end

    def fail_pass
      '&& echo CHECK FAILED || echo CHECK PASSED'
    end

    def check_package package, exists = true
      "dpkg --get-selections | grep #{package}.*#{exists ? '' : 'de'}install #{pass_fail}"
    end

    def check_gem gem, version = nil
      version = " -v #{version}" if version
      "gem search #{gem}#{version} --installed #{pass_fail}"
    end

    def check_file file, exists = true
      "test -s #{file} #{exists ? pass_fail : fail_pass}"
    end

    def check_link link
      "test -L #{link} #{pass_fail}"
    end


    def check_dir dir, exists = true
      "test -d #{dir} #{exists ? pass_fail : fail_pass}"
    end

    def check_perms perms, path
      mods = %w(--- --x -w- -wx r-- r-x rw- rwx)
      "ls -la #{path} | grep #{mods[perms[0..0].to_i]}#{mods[perms[1..1].to_i]}#{mods[perms[2..2].to_i]} #{pass_fail}"
    end

    def check_owner user, path
      "ls -la #{path} | grep '#{user}.*#{user}' #{pass_fail}"
    end

    def check_string string, file
      "grep '#{string}' #{file} #{pass_fail}"
    end

    def check_daemon daemon
      "ps aux | grep #{daemon} #{pass_fail}"
    end

    def check_init_d name
      "test -L /etc/rc0.d/K20#{name} #{pass_fail}"
    end
  end
end

