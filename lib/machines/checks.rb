module Machines
  module Checks
    # write a check command to /some/path/where/such/a/thing/should/be/saved
    def add_check check

    end

    def check_packages packages

    end

    # Checks the existence of a file
    def check_file file, exists = true

    end

    def check_dir dir, exists = true

    end

    def check_perms perms, path

    end

    def check_owner user, path

    end

    # Checks a string exists in a file
    def check_string string, file

    end

    # Checks an export exists
    def check_env key, value

    end

    def check_log(string)

    end
  end
end

