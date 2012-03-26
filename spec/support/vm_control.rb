require 'net/ssh'

class VmControl
  def initialize
    @vm = 'machinesvm'
  end

  def start
    vboxmanage "startvm #{@vm} --type headless"
  end

  def stop
    vboxmanage "controlvm #{@vm} savestate"
  end

  def kill
    vboxmanage "controlvm #{@vm} poweroff"
  end

  def restore
    vboxmanage "snapshot #{@vm} restorecurrent"
  end

  def state
    output = vboxmanage "showvminfo #{@vm} | grep State"
    output.scan(/State:\s+(.*)/).first.first
  end

  def vboxmanage command
    `VBoxManage #{command}`
  end
end

class WinVmControl < VmControl
  def vboxmanage command
    output = ''
    begin
      Net::SSH.start('winhost', 'vbuser', :timeout => 10) do |ssh|
        output = ssh.exec!("C:\\Program Files\\Oracle\\VirtualBox\\VBoxManage #{command}")
      end
    rescue Timeout::Error => e
      output = false
    end
    output
  end
end

