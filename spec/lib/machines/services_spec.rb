require 'spec_helper'

describe 'Services' do
  include Machines::Core
  include Machines::FileOperations
  include Machines::Services

  describe 'restart' do
    subject { restart 'daemon' }
    it { subject.command.must_equal 'service daemon restart' }
  end

  describe 'start' do
    it 'start daemon and check it runs' do
      subject = start 'daemon'
      subject.command.must_equal 'service daemon start'
      subject.check.must_equal 'ps aux | grep daemon | grep -v grep && echo CHECK PASSED || echo CHECK FAILED'
    end

    it 'start daemon with no checking' do
      subject = start 'daemon', :check => false
      subject.check.must_equal nil
    end
  end
end

