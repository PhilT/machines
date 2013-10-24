require 'spec_helper'

describe 'packages/ssh_keygen' do
  before do
    $conf.machine_name = 'machine'
    $conf.machine = AppConf.new
  end

  it 'generates an ssh key locally, stores in memory and removes' do
    FakeFS.deactivate!
    Core.any_instance.stubs(:agree).returns true
    proc { eval_package }.must_output /Copy the following key.*ssh-rsa/m

    $conf.id_rsa.must_match /BEGIN RSA PRIVATE KEY/
    $conf.id_rsa_pub.must_match /ssh-rsa/
    File.exists?('tmp/machine_id_rsa').must_equal false
    File.exists?('tmp/machine_id_rsa.pub').must_equal false
  end

  it 'exits when answering no to continue question' do
    Core.any_instance.stubs(:system)
    FileUtils.touch 'tmp/machine_id_rsa'
    FileUtils.touch 'tmp/machine_id_rsa.pub'
    Core.any_instance.expects(:agree).returns false
    Core.any_instance.expects(:exit)
    eval_package
  end

  describe 'using local keys' do
    before do
      FileUtils.mkdir_p(File.join(ENV['HOME'], '.ssh'))
      File.open(File.join(ENV['HOME'], '.ssh/id_rsa'), 'w') { |f| f.write 'rsa private key' }
      File.open(File.join(ENV['HOME'], '.ssh/id_rsa.pub'), 'w') { |f| f.write 'rsa public key' }
    end

    it 'uses local key on dryrun' do
      $conf.log_only = true
      eval_package
      $conf.id_rsa.must_equal 'rsa private key'
      $conf.id_rsa_pub.must_equal 'rsa public key'
    end

    it 'uses local key when use_local_ssh_id is set' do
      $conf.machine.use_local_ssh_id = true
      eval_package
      $conf.id_rsa.must_equal 'rsa private key'
      $conf.id_rsa_pub.must_equal 'rsa public key'
    end

    it 'adds commands to write ssh keys' do
      $conf.log_only = true
      eval_package
      queued_commands.must_equal [
        'TASK   ssh_keygen - Generate SSH key and present it',
        'RUN    mkdir -p .ssh',
        'UPLOAD buffer from private ssh key to .ssh/id_rsa',
        'UPLOAD buffer from public ssh key to .ssh/id_rsa.pub'
      ].join("\n")
    end
  end
end