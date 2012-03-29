require 'spec_helper'

describe 'Questions' do
  describe 'enter_password' do
    before(:each) do
      stubs(:ask).returns 'password'
    end

    it 'does not echo output' do
      mock_question = mock HighLine::Question
      mock_question.expects(:echo=).with(false).twice
      stubs(:ask).yields(mock_question).returns 'password'
      enter_password 'type'
    end

    it 'prompts for a password' do
      expects(:ask).with('Enter type password: ').once.returns 'password'
      enter_password('type')
    end

    it 'returns password' do
      enter_password('type').must_equal 'password'
    end

    it 'adds to password list' do
      enter_password('type')
      AppConf.passwords.must_equal ['password']
    end

    it 'does not add password less than 5 characters to password list' do
      stubs(:ask).returns 'pass'
      enter_password('type')
      AppConf.passwords.must_equal []
    end

    it 'repeats until password and confirmation match' do
      expects(:ask).with('Enter type password: ').twice.returns 'password'
      expects(:ask).with('Confirm the password: ').twice.returns 'pas', 'password'
      expects(:say).with('Passwords do not match, please re-enter')
      enter_password('type').must_equal 'password'
    end

    it 'only asks once when confirm set to false' do
      expects(:ask).with('Enter type password: ').once.returns 'password'
      should_not_receive(:ask).with('Confirm the password: ')
      enter_password('type', false)
    end

    it 'password still added to list when not confirming' do
      enter_password('type', false)
      AppConf.passwords.must_equal ['password']
    end

    it 'password still returned when not confirming' do
      enter_password('type', false).must_equal 'password'
    end

    it 'do not add to passwords list if not available' do
      AppConf.passwords = nil
      enter_password('type')
      AppConf.passwords.should be_nil
    end
  end
end

