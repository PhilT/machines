require 'spec_helper'

describe 'CommandLine' do
  describe 'execute' do
    it 'calls specified action' do
      %w(htpasswd dryrun build).each do |action|
        should_receive action
        execute [action]
      end
    end

    it 'calls generate with folder' do
      should_receive(:generate).with(['dir'])
      execute ['new', 'dir']
    end

    it 'calls generate without folder' do
      should_receive(:generate).with([])
      execute ['new']
    end

    it 'calls help when no matching command' do
      execute ['anything']
      $output.should == Help.new.to_s
    end
  end

  describe 'help' do
    it 'delegates to Help class' do
      Help.should_receive(:detailed).and_return 'help'
      help 'required options'
    end
  end

  describe 'htpasswd' do
    it 'htpasswd is generated and saved' do
      AppConf.webserver = 'server'
      $input.answers = %w(user pass pass)
      htpasswd nil
      File.read('server/conf/htpasswd').should =~ /user:.{13}/
    end
  end

  describe 'generate' do
    it 'copies the template' do
      FileUtils.should_receive(:cp_r).with("#{AppConf.application_dir}/template/.", '.')
      FileUtils.should_receive(:mkdir_p).with('./packages')
      generate []
    end

    it 'copies the template within dir' do
      FileUtils.should_receive(:cp_r).with("#{AppConf.application_dir}/template/.", 'dir')
      FileUtils.should_receive(:mkdir_p).with(File.join('dir', 'packages'))
      should_receive(:say).with('Project created at dir/')
      generate ['dir']
    end

    context 'when folder exists' do
      before(:each) do
        FileUtils.mkdir_p('dir')
      end

      it 'is overwritten after user confirmation' do
        should_receive(:ask).with('Folder already exists. Overwrite (y/n)? ').and_return 'y'
        FileUtils.should_receive(:cp_r).with("#{AppConf.application_dir}/template/.", 'dir')
        FileUtils.should_receive(:mkdir_p).with(File.join('dir', 'packages'))
        generate ['dir']
      end

      it 'generation is aborted at user request' do
        should_receive(:ask).with('Folder already exists. Overwrite (y/n)? ').and_return 'n'
        FileUtils.should_not_receive(:cp_r)
        FileUtils.should_not_receive(:mkdir_p)
        generate ['dir']
      end
    end
  end

  describe 'packages' do
    it 'displays a list of default and project packages' do
      FileUtils.mkdir_p File.join(AppConf.application_dir, 'packages')
      FileUtils.mkdir_p 'packages'
      FileUtils.touch File.join(AppConf.application_dir, 'packages', 'base.rb')
      FileUtils.touch File.join('packages', 'apps.rb')
      packages
      $output.should == 'Default packages
 * base
Project packages
 * apps
'
    end
  end

  describe 'override' do
    before(:each) do
      FileUtils.mkdir_p File.join(AppConf.application_dir, 'packages')
      FileUtils.mkdir_p 'packages'
      FileUtils.touch File.join(AppConf.application_dir, 'packages', 'base.rb')
    end

    it 'copies package to project folder' do
      override 'base'
      File.should exist 'packages/base.rb'
    end

    context 'when copying over existing package' do
      before(:each) do
        FileUtils.touch 'packages/base.rb'
      end

      it 'terminates when user answer no' do
        $input.answers = %w(n)
        override 'base'
        $output.should == 'Project package already exists. Overwrite? (y/n)
Aborted.
'
      end

      it 'overwrites project package with default package' do
        $input.answers = %w(y)
        override 'base'
        $output.should == 'Project package already exists. Overwrite? (y/n)
Package copied to packages/base.rb
'
      end
    end
  end
end

