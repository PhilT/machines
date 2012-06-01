require 'spec_helper'

describe 'packages/cruisecontrol' do
  before(:each) do
    load_package('cruisecontrol')
    $conf.from_hash(ruby: {gems_path: 'ruby/gems'})
    $conf.webapps = {'application' =>
      AppBuilder.new(
        'scm' => 'github.com/project',
        'title' => 'Application'
      )
    }
    $conf.from_hash(:mail => {address: 'mailserver', domain: 'domain.net' })
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   cruisecontrol - Install, configure and set to start on boot",
      "RUN    cd cruisecontrol.rb &&  bundle",
      "RUN    cd cruisecontrol.rb &&  ruby ./cruise add Application -r github.com/project",
      "SUDO   cp -rf cruisecontrol.rb/daemon/cruise /etc/init.d/cruise",
      "SUDO   update-rc.d cruise defaults",
      "SUDO   echo \"export CRUISE_HOME=/cruisecontrol.rb\" >> /etc/profile",
      "RUN    echo \"ActionMailer::Base.smtp_settings = {address: mailserver, domain: domain.net}\" >> .cruise/site_config.rb"
    ].join("\n")
  end
end

