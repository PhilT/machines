require 'spec_helper'

describe 'packages/awstats' do
  before(:each) do
    load_package('awstats')
    AppConf.from_hash :awstats => {:url => 'awstats_url', :path => 'awstats_path'}
    FileUtils.mkdir 'awstats'
    File.open('awstats/awstats.conf.erb', 'w') {}
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).must_equal [
      "TASK   awstats - Install AWStats",
      "SUDO   apt-get -q -y install awstats",
      "UPLOAD buffer from awstats/awstats.conf.erb to /tmp/awstats.conf",
      "SUDO   cp -rf /tmp/awstats.conf awstats_path/conf/awstats.conf",
      "RUN    rm -rf /tmp/awstats.conf",
    ]
  end
end

