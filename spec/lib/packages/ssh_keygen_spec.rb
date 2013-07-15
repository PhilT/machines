require 'spec_helper'

describe 'packages/ssh_keygen' do
  before do
    $conf.machine_name = 'machine'
    $conf.machine = AppConf.new
    $conf.use_local_ssh_id = false
  end

  it 'generates an ssh key locally, stores in memory and removes' do
    FakeFS.deactivate!
    Core.any_instance.stubs(:agree).returns true
    proc { eval_package }.must_output /Copy the following key.*ssh-rsa/m

    $conf.id_rsa.must_match /BEGIN RSA PRIVATE KEY/
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

  it "uses user's key on dryrun" do
    FileUtils.mkdir_p(File.join(ENV['HOME'], '.ssh'))
    File.open(File.join(ENV['HOME'], '.ssh/id_rsa'), 'w') { |f| f.write 'rsa private key' }
    FileUtils.touch File.join(ENV['HOME'], '.ssh/id_rsa.pub')
    $conf.log_only = true
    eval_package
    $conf.id_rsa.must_equal 'rsa private key'
    queued_commands.must_equal [
      "TASK   ssh_keygen - Generate SSH key and present it"
    ].join("\n")
  end

  it 'displays public key' do
#    eval_package

  end
end
