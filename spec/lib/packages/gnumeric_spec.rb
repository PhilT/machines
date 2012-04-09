require 'spec_helper'

describe 'packages/apps' do
  before(:each) do
    load_package('gnumeric')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   gnumeric - Install gnumeric lightweight spreadsheet",
      "SUDO   apt-get -q -y install gnumeric",
      "TASK   gnumeric_associations - Setup file associations for Gnumeric",
      "RUN    echo \"application/x-gnumeric=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"text/csv=gnumeric.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    echo \"application/msexcel=gnumeric.desktop\" >> .local/share/applications/mimeapps.list"
    ]
  end
end

