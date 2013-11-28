module Machines
  class Security
    def initialize(password)
      @crypto = GPGME::Crypto.new password: password
    end

    def encrypt(text)
      @crypto.encrypt text, symmetric: true      
    end

    def decrypt(text)
      @crypto.decrypt text
    end
  end
end
