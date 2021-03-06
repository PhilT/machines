require 'spec_helper'

describe 'packages/sqlserver' do
  it 'adds the following commands' do
    eval_package
    $conf.commands.map(&:info).must_equal [
      "TASK   sqlserver - Download and build sqlserver driver",
      "RUN    test -d tiny_tds && (cd tiny_tds && git pull) || git clone --quiet git://github.com/rails-sqlserver/tiny_tds.git",
      "RUN    cd tiny_tds && rake compile && rake native gem"
    ]
  end
end

