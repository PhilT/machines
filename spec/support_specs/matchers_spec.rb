require 'spec_helper'

describe Matchers do
  describe Matchers::BeDisplayed do
    subject { BeDisplayed.new }

    it 'gets the next line from the console' do
      $console.should_receive(:next)
      BeDisplayed.new
    end

    describe 'matches?' do
      it 'a simple string' do
        $console.stub(:next).and_return 'simple string'
        subject.matches?('simple string').should be_true
      end

      it 'fails a simple match' do
        $console.stub(:next).and_return 'simple string'
        subject.matches?('wrong string').should be_false
      end

      it 'a line' do
        $console.stub(:next).and_return "a line\n"
        subject.matches?("a line\n").should be_true
      end

      it 'two blank lines' do
        $console.stub(:next).and_return "\n\n"
        subject.matches?("\n\n").should be_true
      end

      it 'a line with return' do
        $console.stub(:next).and_return "line with return\r"
        subject.matches?("line with return\r").should be_true
      end

      it 'a line with colour' do
        $console.stub(:next).and_return $terminal.color('line with colour', :blue) + "\n"
        subject = BeDisplayed.new :blue
        subject.matches?("line with colour\n").should be_true
      end

      it 'a line with wrong colour' do
        $console.stub(:next).and_return $terminal.color('line with colour', :blue) + "\n"
        subject = BeDisplayed.new :red
        subject.matches?("line with colour\n").should be_false
      end
    end

    describe 'failure_message' do
      it 'returns message' do
        $console.stub(:next).and_return 'something else'
        subject.matches?('something')
        subject.failure_message.should == 'expected "something" but got "something else"'
      end
    end

    describe 'negative_failure_message' do
      it 'returns message' do
        subject.matches?('something')
        subject.negative_failure_message.should == 'expected something other than "something"'
      end
    end

    describe 'be_displayed' do
      it 'instaniates BeDisplayed' do
        be_displayed.should be_a BeDisplayed
      end

      it 'passes the colour' do
        $console.stub(:next).and_return $terminal.color('something', :blue)
        subject = be_displayed(:blue)
        subject.matches?('something').should be_true
      end
    end

    describe 'method_missing' do
      it 'in_something converts to a string' do
        in_something.should == 'something'
      end

      it 'as_something converts to a string' do
        as_something.should == 'something'
      end
    end
  end

  describe Matchers::BeLogged do
    subject { BeLogged.new }

    it 'gets the next line from the console' do
      $file.should_receive(:next)
      BeLogged.new
    end

    describe 'be_logged' do
      it 'instaniates BeLogged' do
        be_logged.should be_a BeLogged
      end

      it 'passes the colour' do
        $file.stub(:next).and_return $terminal.color('something', :blue)
        subject = be_logged(:blue)
        subject.matches?('something').should be_true
      end
    end
  end
end

