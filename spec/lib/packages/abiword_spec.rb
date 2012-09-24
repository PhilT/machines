require 'spec_helper'

describe 'packages/apps' do
  before(:each) do
    load_package('abiword')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   abiword - Install a lightweight word processor",
      "SUDO   apt-get -q -y install abiword",
      "TASK   abiword_assoc - Setup file associations for Abiword",
      "RUN    grep \"application/x-abiword=abiword.desktop\" .local/share/applications/mimeapps.list || echo \"application/x-abiword=abiword.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"application/msword=abiword.desktop\" .local/share/applications/mimeapps.list || echo \"application/msword=abiword.desktop\" >> .local/share/applications/mimeapps.list",
      "RUN    grep \"application/rtf=abiword.desktop\" .local/share/applications/mimeapps.list || echo \"application/rtf=abiword.desktop\" >> .local/share/applications/mimeapps.list"
    ]
  end
end

