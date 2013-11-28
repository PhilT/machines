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

        if $passwords.to_filter && password.size > 4 && password != 'password'
          $passwords.to_filter << password
        end
        password
      end
    end
  end
end
