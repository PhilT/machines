require 'spec_helper'

describe 'packages/sqlserver' do
  before(:each) do
    load_package('sqlserver')
  end

  it 'adds the following commands' do
    eval_package
    AppConf.commands.map(&:info).must_equal [
      "TASK   sqlserver - Download and build sqlserver driver",
      "RUN    git clone -q git://github.com/rails-sqlserver/tiny_tds.git",
      "RUN    cd tiny_tds && rake compile && rake native gem"
    ]
  end
end

