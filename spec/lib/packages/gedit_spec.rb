require 'spec_helper'

describe 'packages/gedit' do
  it 'adds the following commands' do
    eval_package
    queued_commands.must_equal [
      "TASK   gedit - Install basic programmers editor and set associations",
      "SUDO   apt-get -q -y install python-gi-cairo",
      "SUDO   apt-get -q -y install gedit",
      "RUN    grep \"text/plain=gedit.desktop\" .local/share/applications/mimeapps.list || echo \"text/plain=gedit.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"application/x-ruby=gedit.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-ruby=gedit.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"application/x-shellscript=gedit.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-shellscript=gedit.desktop\" >> .local/share/applications/mimeapps.list",
    ].join("\n")
  end
end

