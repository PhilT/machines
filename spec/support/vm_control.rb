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

