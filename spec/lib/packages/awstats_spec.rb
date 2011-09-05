require 'spec_helper'

describe 'packages/awstats' do
  before(:each) do
    load_package('awstats')
    AppConf.from_hash :awstats => {:url => 'awstats_url', :path => 'awstats_path'}
    File.open('/prj/awstats/awstats.conf.erb', 'w') {|f| f.puts 'awstats template' }
    @time = Time.now
    Time.stub(:now).and_return @time
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   awstats - Download and install AWStats",
      "SUDO   cd /tmp && wget awstats_url && tar -zxf awstats_url && mv awstats_url awstats_path && rm awstats_url && cd -",
      "UPLOAD buffer from /prj/awstats/awstats.conf.erb to /tmp/upload#{@time.to_i}",
      "SUDO   cp /tmp/upload#{@time.to_i} awstats_path/conf/awstats.conf",
      "RUN    rm -f /tmp/upload#{@time.to_i}",
    ]
  end
end

