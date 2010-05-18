module Machines
  module Checks
    def check_packages packages
      packages.map{|package| "dpkg --get-selections | grep #{package}; echo #{package} installed? $?"}
    end

    def check_gem gem, version
      version = " -v #{version}" if version
      "gem search #{gem}#{version} --installed"
    end

    # Checks the existence of a file
    def check_file file, exists = true
      ""
    end

    def check_link link
      ""
    end


    def check_dir dir, exists = true
      ""
    end

    def check_perms perms, path
      ""
    end

    def check_owner user, path
      ""
    end

    # Checks a string exists in a file
    def check_string string, file
      ""
    end

    # Checks an export exists
    def check_env key, value
      ""
    end

    def check_log string
      ""
    end

    def check_daemon daemon
      ""
    end

    def check_init_d name
      "ls /etc/rc?.d | grep #{name}"
    end
  end
end

