require 'spec_helper'

describe 'packages/ruby' do
  before(:each) do
    load_package('ruby')
    AppConf.ruby = AppConf.new
    AppConf.ruby.version = '1.9.2'
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).should == [
      "TASK   ruby - Install Ruby, make 1.9.2@global the default and install Bundler",
      "RUN    rvm install 1.9.2",
      "RUN    rvm 1.9.2@global --default",
      "UPLOAD buffer from .gemrc to .gemrc",
      "RUN    gem install bundler"
    ]
  end
end

