module Machines
  module Questions
    def choose_machine
      choose(*AppConf.machines.keys) { |menu| menu.prompt = 'Select machine to build: ' }
    end

    def enter_password(type, confirm = true)
      begin
        password = ask("Enter #{type} password: ") { |question| question.echo = false }
        break unless confirm
        password_confirmation = ask('Confirm the password: ') { |question| question.echo = false }
        say "Passwords do not match, please re-enter" unless password == password_confirmation
      end while password != password_confirmation
      AppConf.passwords << password if AppConf.passwords && password.size > 4
      password
    end
  end
end

