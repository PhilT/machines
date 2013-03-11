module Machines
  module Commands
    module Questions
      def enter_password(type, confirm = true)
        begin
          password = ask("Enter #{type} password: ") { |question| question.echo = false }
          break unless confirm
          password_confirmation = ask('Confirm the password: ') { |question| question.echo = false }
          say "Passwords do not match, please re-enter" unless password == password_confirmation
        end while password != password_confirmation
        $conf.passwords << password if $conf.passwords && password.size > 4 && password != 'password'
        password
      end
    end
  end
end
