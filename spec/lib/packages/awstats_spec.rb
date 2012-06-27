require 'spec_helper'

describe 'packages/awstats' do
  before(:each) do
    load_package('awstats')
    $conf.webapps = {'name' => AppBuilder.new({:name => 'appname', :path => 'apppath'})}
    FileUtils.mkdir('misc')
    File.open('misc/awstats.conf.erb', 'w') {}
  end

  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).join("\n").must_equal [
      "TASK   awstats - Install AWStats",
      "SUDO   apt-get -q -y install awstats",
      "SUDO   wget https://raw.github.com/PhilT/bin/master/awstats_render -O /usr/local/bin/awstats_render",
      "SUDO   chmod +x /usr/local/bin/awstats_render",
      "UPLOAD buffer from misc/awstats.conf.erb to /tmp/awstats..conf",
      "SUDO   cp -rf /tmp/awstats..conf /etc/awstats/awstats..conf",
      "RUN    rm -rf /tmp/awstats..conf",
      "RUN    mkdir -p /name_stats/data",
      "RUN    mkdir -p /name_stats/public",
    ].join("\n")
  end
end

