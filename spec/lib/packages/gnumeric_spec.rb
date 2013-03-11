require 'spec_helper'

describe 'packages/gnumeric' do
  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   gnumeric - Install gnumeric lightweight spreadsheet",
      "SUDO   apt-get -q -y install gnumeric",
      "TASK   gnumeric_assoc - Setup file associations for Gnumeric",
      "RUN    grep \"application/x-gnumeric=gnumeric.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-gnumeric=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=gnumeric.desktop\" .local/share/applications/mimeapps.list || echo \"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"text/csv=gnumeric.desktop\" .local/share/applications/mimeapps.list || echo \"text/csv=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"application/msexcel=gnumeric.desktop\" .local/share/applications/mimeapps.list || echo \"application/msexcel=gnumeric.desktop\" >> .local/share/applications/mimeapps.list"
    ]
  end
end

