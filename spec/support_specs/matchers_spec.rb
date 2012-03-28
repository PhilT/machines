require 'spec_helper'

describe Matchers do
  describe Matchers::BeDisplayed do
    subject { BeDisplayed.new }

    it 'gets the next line from the console' do
      $console.expects(:next)
      BeDisplayed.new
    end

    describe 'matches?' do
      it 'a simple string' do
        $console.stubs(:next).returns 'simple string'
        subject.matches?('simple string').must_equal true
      end

      it 'fails a simple match' do
        $console.stubs(:next).returns 'simple string'
        subject.matches?('wrong string').must_equal false
      end

      it 'a line' do
        $console.stubs(:next).returns "a line\n"
        subject.matches?("a line\n").must_equal true
      end

      it 'two blank lines' do
        $console.stubs(:next).returns "\n\n"
        subject.matches?("\n\n").must_equal true
      end

      it 'a line with return' do
        $console.stubs(:next).returns "line with return\r"
        subject.matches?("line with return\r").must_equal true
      end

      it 'a line with colour' do
        $console.stubs(:next).returns $terminal.color('line with colour', :blue) + "\n"
        subject = BeDisplayed.new :blue
        subject.matches?("line with colour\n").must_equal true
      end

      it 'a line with wrong colour' do
        $console.stubs(:next).returns $terminal.color('line with colour', :blue) + "\n"
        subject = BeDisplayed.new :red
        subject.matches?("line with colour\n").must_equal false
      end
    end

    describe 'failure_message' do
      it 'returns message' do
        $console.stubs(:next).returns 'something else'
        subject.matches?('something')
        subject.failure_message.must_equal 'expected "something" but got "something else"'
      end
    end

    describe 'negative_failure_message' do
      it 'returns message' do
        subject.matches?('something')
        subject.negative_failure_message.must_equal 'expected something other than "something"'
      end
    end

    describe 'be_displayed' do
      it 'instaniates BeDisplayed' do
        be_displayed.should be_a BeDisplayed
      end

      it 'passes the colour' do
        $console.stubs(:next).returns $terminal.color('something', :blue)
        subject = be_displayed(:blue)
        subject.matches?('something').must_equal true
      end
    end

    describe 'method_missing' do
      it 'in_something converts to a string' do
        in_something.must_equal 'something'
      end

      it 'as_something converts to a string' do
        as_something.must_equal 'something'
      end
    end
  end

  describe Matchers::BeLogged do
    subject { BeLogged.new }

    it 'gets the next line from the console' do
      $file.expects(:next)
      BeLogged.new
    end

    describe 'be_logged' do
      it 'instaniates BeLogged' do
        be_logged.must_be_instance_of BeLogged
      end

      it 'passes the colour' do
        $file.stubs(:next).returns $terminal.color('something', :blue)
        subject = be_logged(:blue)
        subject.matches?('something').must_equal true
      end
    end
  end
end

