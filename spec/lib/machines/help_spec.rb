require 'spec_helper'

describe Machines::Help do
  subject { Machines::Help.new }

  describe 'actions' do
    it { subject.actions.must_equal ['htpasswd', 'new', 'dryrun', 'tasks', 'build', 'list', 'packages', 'override'] }
  end

  describe 'machine_list' do
    it 'lists the machines from machines.yml' do
      File.open('machines.yml', 'w') {|f| f.puts({'machines' => {'machine_1' => {}, 'machine_2' => {}}}.to_yaml) }
      subject.machine_list.must_equal "Machines from machines.yml:\n  machine_1\n  machine_2\n"
    end
  end

  describe 'syntax' do
    it 'includes version' do
      subject.syntax.must_match /machines v0\.[0-9]+\.[0-9]+ - Ubuntu\/Ruby configuration tool\./
    end

    it 'includes syntax' do
      subject.syntax.must_match /machines COMMAND/
      subject.syntax.must_match /COMMAND can be:/
      subject.syntax.must_match /build \<machine\> \[task\]   Builds your chosen machine/
    end
  end
end

