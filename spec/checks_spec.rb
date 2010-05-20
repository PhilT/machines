require 'spec/spec_helper'

describe 'Checks' do
  describe 'pass_fail' do
    it do
      pass_fail.should == '&& echo CHECK PASSED || echo CHECK FAILED'
    end
  end

  describe 'fail_pass' do
    it do
      fail_pass.should == '&& echo CHECK FAILED || echo CHECK PASSED'
    end
  end

  describe 'check_packages' do
    it do
      check_packages(%w(package1 package2)).should == "dpkg --get-selections | grep -F 'package1\npackage2' && echo CHECK PASSED || echo CHECK FAILED"
    end
  end

  describe 'check_gem' do
    it do
      check_gem('gem').should == 'gem search gem --installed && echo CHECK PASSED || echo CHECK FAILED'
    end

    it do
      check_gem('gem', '1.2.3').should == 'gem search gem -v 1.2.3 --installed && echo CHECK PASSED || echo CHECK FAILED'
    end
  end

  describe 'check_file' do
    it do
      check_file('file').should == 'test -s file && echo CHECK PASSED || echo CHECK FAILED'
    end

    it do
      check_file('file', false).should == 'test -s file && echo CHECK FAILED || echo CHECK PASSED'
    end
  end

  describe 'check_link' do
    it do
      check_link('link').should == 'test -L link && echo CHECK PASSED || echo CHECK FAILED'
    end
  end

  describe 'check_dir' do
    it do
      check_dir('dir').should == 'test -d dir && echo CHECK PASSED || echo CHECK FAILED'
    end

    it do
      check_dir('dir', false).should == 'test -d dir && echo CHECK FAILED || echo CHECK PASSED'
    end
  end

  describe 'check_perms' do
    it do
      check_perms('764', 'path').should == 'ls -la path | grep rwxrw-r-- && echo CHECK PASSED || echo CHECK FAILED'
    end

    it do
      check_perms('235', 'path').should == 'ls -la path | grep -w--wxr-x && echo CHECK PASSED || echo CHECK FAILED'
    end
  end

  describe 'check_owner' do
    it do
      check_owner('owner', 'path').should == "ls -la path | grep 'owner owner' && echo CHECK PASSED || echo CHECK FAILED"
    end
  end

  describe 'check_string' do
    it do
      check_string('string', 'file').should == "grep 'string' file && echo CHECK PASSED || echo CHECK FAILED"
    end
  end

  describe 'check_daemon' do
    it do
      check_daemon('daemon').should == 'ps aux | grep daemon && echo CHECK PASSED || echo CHECK FAILED'
    end
  end

  describe 'check_init_d' do
    it do
      check_init_d('name').should == 'test -L /etc/rc0.d/K20name && echo CHECK PASSED || echo CHECK FAILED'
    end
  end
end

