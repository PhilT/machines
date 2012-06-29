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
    $conf.user = 'user'
    $conf.user_home = '/home/user'
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   cruisecontrol - Install, configure and set to start on boot",
      "RUN    git clone --quiet https://github.com/thoughtworks/cruisecontrol.rb.git",
      "RUN    cd cruisecontrol.rb &&  bundle",
      "RUN    cd cruisecontrol.rb &&  ruby ./cruise add Application -r github.com/project",
      "SUDO   cp -rf cruisecontrol.rb/daemon/cruise /etc/init.d/cruise",
      "SUDO   update-rc.d cruise defaults",
      "SUDO   sed -i \"s/CRUISE_USER = .*/CRUISE_USER = 'user'/\" /etc/init.d/cruise",
      "SUDO   sed -i \"s/CRUISE_HOME = .*/CRUISE_HOME = '\\/home\\/user\\/cruisecontrol.rb'/\" /etc/init.d/cruise",
      "RUN    grep \"ActionMailer::Base.smtp_settings = {address: 'mailserver', domain: 'domain.net'}\" .cruise/site_config.rb || echo \"ActionMailer::Base.smtp_settings = {address: 'mailserver', domain: 'domain.net'}\" >> .cruise/site_config.rb"
    ].join("\n")
  end
end

