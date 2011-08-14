require 'spec_helper'

describe 'packages/awstats' do
  before(:each) do
    load_package('awstats')
    AppConf.from_hash :awstats => {:url => 'awstats_url', :path => 'awstats_path'}
    File.open('/prj/awstats/awstats.conf.erb', 'w') {|f| f.puts 'awstats template' }
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      'TASK   awstats - Download and install AWStats',
      "SUDO   cd /tmp && wget awstats_url && tar -zxf awstats_url && mv awstats_url awstats_path && rm awstats_url && cd -",
      "SUDO   echo \"awstats template\n\" > awstats_path/conf/awstats.conf"
    ]
  end
end

