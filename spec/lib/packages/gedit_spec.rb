require 'spec_helper'

describe 'packages/apps' do
  before(:each) do
    load_package('gedit')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   gedit - Install basic programmers editor and set associations",
      "SUDO   apt-get -q -y install python-gi-cairo",
      "SUDO   apt-get -q -y install gedit",
      "RUN    echo \"text/plain=gedit.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-ruby=gedit.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/x-shellscript=gedit.desktop\" >> .local/share/applications/mimeapps.list",
    ].join("\n")
  end
end

