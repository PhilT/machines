require 'spec_helper'

describe 'Questions' do
  include Machines::Questions

  describe 'choose_machine' do
    before(:each) do
      File.stub(:read).with("#{AppConf.project_dir}/Machinesfile").and_return <<-MACHINESFILE
machine 'Desktop', :development, :roles => [:app, :db], :apps => ['main', 'wiki']
machine 'Staging', :staging, :roles => [:app, :db], :apps => ['main', 'wiki']
machine 'Production', :production, :roles => :app, :apps => ['main', 'wiki']
MACHINESFILE
    end

    it 'loads options from Machinesfile' do
      mock_menu = mock HighLine::Menu, :prompt => nil
      should_receive(:choose).with('Desktop', 'Staging', 'Production').and_yield mock_menu
      choose_machine
    end
  end
end

