require 'spec_helper'

describe 'packages/postfix' do
  it 'adds the following commands' do
    $conf.from_hash(:mail => {:domain => 'domain'})
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   postfix - Install postfix mail",
      "SUDO   echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections",
      "SUDO   echo postfix postfix/mailname string domain | debconf-set-selections",
      "SUDO   apt-get -q -y install postfix"
    ]
  end
end

