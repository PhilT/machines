require 'spec_helper'

describe 'packages/postfix' do
  before(:each) do
    load_package('postfix')
    AppConf.from_hash(:mail => {:domain => 'domain'})
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   postfix - Install postfix mail",
      "SUDO   echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections",
      "SUDO   echo postfix postfix/mailname string domain | debconf-set-selections",
      "SUDO   apt-get -q -y install postfix"
    ]
  end
end
