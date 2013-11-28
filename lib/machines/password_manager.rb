module Machines
  class PasswordManager
    def initialize
      @passwords = AppConf.new
    end

    def load_passwords
      if $conf.log_only
        @passwords.to_filter << @passwords.master_password = 'pa55word'
      else
        if File.exist?('passwords.gpg')
          create_passwords_gpg
          confirm = false
        else
          load_passwords_gpg
          say "Generating master password store (do not forget the Master password!)"
          confirm = true
        end
      end

      @passwords.master_password = enter_password('Master', confirm)
      security = Security.new(@passwords.master_password)
      hash = YAML.load(security.decrypt('passwords.gpg'))
      @passwords.from_hash(hash)
      @passwords
    end
  end
end