require 'spec_helper'

describe 'packages/amazon_mp3' do
  before(:each) do
    load_package('amazon_mp3')
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   amazon_mp3 - Download and install MP3 downloader from Amazon",
      "SUDO   cd /tmp && wget http://www.hilltopyodeler.com/packages/AmazonMP3-InstallerForUbuntuNewerThan-9.04.tar.gz && tar -xfz AmazonMP3-InstallerForUbuntuNewerThan-9.04.tar.gz && rm AmazonMP3-InstallerForUbuntuNewerThan-9.04.tar.gz && cd -",
      "SUDO   cd /tmp/AmazonMP3-InstallerForUbuntuNewerThan-9.04 && dpkg -i --force-architecture *.deb && cd - && rm -rf /tmp/AmazonMP3-InstallerForUbuntuNewerThan-9.04"
    ]
  end
end

