require 'spec_helper'

describe Machines::Commands::Questions do
  describe 'enter_password' do
    before(:each) do
      stubs(:ask).returns 'pa55word'
    end

    it 'does not echo output' do
      mock_question = mock 'HighLine::Question'
      mock_question.expects(:echo=).with(false).twice
      stubs(:ask).yields(mock_question).returns 'pa55word'
      enter_password 'type'
    end

    it 'prompts for a password' do
      expects(:ask).with('Enter type password: ').once.returns 'pa55word'
      enter_password('type')
    end

    it 'returns password' do
      enter_password('type').must_equal 'pa55word'
    end

    it 'adds to password list' do
      enter_password('type')
      $conf.passwords.must_equal ['pa55word']
    end

    it 'does not add password less than 5 characters to password list' do
      stubs(:ask).returns 'pass'
      enter_password('type')
      $conf.passwords.must_equal []
    end

    it 'does not add password if it is "password"' do
      stubs(:ask).returns 'password'
      enter_password('type')
      $conf.passwords.must_equal []
    end

    it 'repeats until password and confirmation match' do
      expects(:ask).with('Enter type password: ').twice.returns 'pa55word'
      expects(:ask).with('Confirm the password: ').twice.returns 'pas', 'pa55word'
      expects(:say).with('Passwords do not match, please re-enter')
      enter_password('type').must_equal 'pa55word'
    end

    it 'only asks once when confirm set to false' do
      expects(:ask).with('Enter type password: ').once.returns 'pa55word'
      expects(:ask).with('Confirm the password: ').never
      enter_password('type', false)
    end

    it 'password still added to list when not confirming' do
      enter_password('type', false)
      $conf.passwords.must_equal ['pa55word']
    end

    it 'password still returned when not confirming' do
      enter_password('type', false).must_equal 'pa55word'
    end

    it 'do not add to passwords list if not available' do
      $conf.passwords = nil
      enter_password('type')
      $conf.passwords.must_equal nil
    end
  end
end

