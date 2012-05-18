require 'spec_helper'

describe Machines::Help do
  subject { Machines::Help.new }

  describe 'actions' do
    it { subject.actions.must_equal ['htpasswd', 'new', 'dryrun', 'tasks', 'build', 'list', 'packages', 'override'] }
  end

  describe 'syntax' do
    it 'includes version' do
      subject.syntax.must_match /machines v0\.[0-9]+\.[0-9]+ - Ubuntu\/Ruby configuration tool\./
    end

    it 'includes syntax' do
      subject.syntax.must_match /machines COMMAND/
      subject.syntax.must_match /COMMAND can be:/
      subject.syntax.must_match /build <machine> \[task\]   Builds your chosen machine\. Optionally, build just one task/
    end
  end
end

