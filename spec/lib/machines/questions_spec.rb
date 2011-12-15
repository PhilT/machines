require 'spec_helper'

describe 'Questions' do
  describe 'enter_password' do
    before(:each) do
      stub!(:ask).and_return 'password'
    end

    it 'does not echo output' do
      mock_question = mock HighLine::Question
      mock_question.should_receive(:echo=).with(false).twice
      stub!(:ask).and_yield(mock_question).and_return 'password'
      enter_password 'type'
    end

    it 'prompts for a password' do
      should_receive(:ask).with('Enter type password: ').once.and_return 'password'
      enter_password('type')
    end

    it 'returns password' do
      enter_password('type').should == 'password'
    end

    it 'adds to password list' do
      enter_password('type')
      AppConf.passwords.should == ['password']
    end

    it 'does not add password less than 5 characters to password list' do
      stub!(:ask).and_return 'pass'
      enter_password('type')
      AppConf.passwords.should == []
    end

    it 'repeats until password and confirmation match' do
      should_receive(:ask).with('Enter type password: ').twice.and_return 'password'
      should_receive(:ask).with('Confirm the password: ').twice.and_return 'pas', 'password'
      should_receive(:say).with('Passwords do not match, please re-enter')
      enter_password('type').should == 'password'
    end

    it 'only asks once when confirm set to false' do
      should_receive(:ask).with('Enter type password: ').once.and_return 'password'
      should_not_receive(:ask).with('Confirm the password: ')
      enter_password('type', false)
    end

    it 'password still added to list when not confirming' do
      enter_password('type', false)
      AppConf.passwords.should == ['password']
    end

    it 'password still returned when not confirming' do
      enter_password('type', false).should == 'password'
    end

    it 'do not add to passwords list if not available' do
      AppConf.passwords = nil
      enter_password('type')
      AppConf.passwords.should be_nil
    end
  end
end

