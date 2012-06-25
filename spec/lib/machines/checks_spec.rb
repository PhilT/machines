require 'spec_helper'

describe 'Checks' do
  describe 'echo_result' do
    it do
      echo_result.must_equal '&& echo CHECK PASSED || echo CHECK FAILED'
    end
  end

  describe 'package' do
    it 'exists' do
      check_package('package1').must_equal "dpkg --get-selections | grep package1.*install #{echo_result}"
    end

    it 'does not exist' do
      check_package('package1', false).must_equal "dpkg --get-selections | grep package1.*deinstall #{echo_result}"
    end
  end

  describe 'check_gem' do
    it do
      check_gem('gem').must_equal "gem search gem --installed #{echo_result}"
    end

    it do
      check_gem('gem', '1.2.3').must_equal "gem search gem -v 1.2.3 --installed #{echo_result}"
    end
  end

  describe 'check_file' do
    it do
      check_file('file').must_equal "test -s file #{echo_result}"
    end

    it do
      check_file('file', false).must_equal "test ! -s file #{echo_result}"
    end
  end

  describe 'check_link' do
    it do
      check_link('link').must_equal "test -L link #{echo_result}"
    end
  end

  describe 'check_dir' do
    it do
      check_dir('dir').must_equal "test -d dir #{echo_result}"
    end

    it do
      check_dir('dir', false).must_equal "test ! -d dir #{echo_result}"
    end
  end

  describe 'check_perms' do
    it do
      check_perms('764', 'path').must_equal "ls -la path | grep rwxrw-r-- #{echo_result}"
    end

    it do
      check_perms('235', 'path').must_equal "ls -la path | grep -w--wxr-x #{echo_result}"
    end
  end

  describe 'check_owner' do
    it do
      check_owner('owner', 'path').must_equal "ls -la path | grep \"owner.*owner\" #{echo_result}"
    end
  end

  describe 'check_string' do
    it do
      check_string('string', 'file').must_equal "grep \"string\" file #{echo_result}"
    end
  end

  describe 'check_daemon' do
    it do
      check_daemon('daemon').must_equal "ps aux | grep daemon | grep -v grep #{echo_result}"
    end

    it do
      check_daemon('daemon', false).must_equal "ps aux | grep daemon | grep -v grep | grep -v daemon #{echo_result}"
    end
  end

  describe 'check_init_d' do
    it do
      check_init_d('name').must_equal "test -L /etc/rc0.d/K20name #{echo_result}"
    end
  end

  describe 'check_command' do
    it do
      check_command('command', 'match').must_equal "command | grep match #{echo_result}"
    end

    it do
      check_command('command').must_equal "command #{echo_result}"
    end

  end
end

