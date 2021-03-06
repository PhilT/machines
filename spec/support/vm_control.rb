require 'net/ssh'

class VmControl
  def initialize
    @name = 'machinesvm'
  end

  def start
    vboxmanage "startvm #{@name} --type headless"
  end

  def stop
    vboxmanage "controlvm #{@name} savestate"
  end

  def kill
    return unless state =~ /running/
    vboxmanage "controlvm #{@name} poweroff"
  end

  def restore
    vboxmanage "snapshot #{@name} restorecurrent"
  end

  def state
    string = "showvminfo #{@name}"
    output = vboxmanage string
    output.scan(/State:\s+(.*)/).first.first
  end

  def vboxmanage command
    send File.read('.vmcontrol').gsub("\n", ''), command
  rescue Errno::ENOENT
    raise '.vmcontrol does not exist. Add `local` to test using VMs on a Linux host or add `remote` to test on a VM running on Windows.'
  end

private
  def local command
    output = `VBoxManage #{command}`
  end

  def remote command
    output = ''
    begin
      Net::SSH.start('winhost', 'vbuser', :timeout => 10) do |ssh|
        output = ssh.exec!("C:\\Program Files\\Oracle\\VirtualBox\\VBoxManage #{command}")
      end
    rescue Timeout::Error => e
      raise 'Connection timed out. Did you start your SSH server on the host?'
    end
    output
  end
end

