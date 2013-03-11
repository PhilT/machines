If installing to VirtualBox on a Windows host (as in my case) read on.

Install freeSSHd
----------------------------------------

* Do not install as a service
* Load FreeSSHd and click on the system tray icon
* Under "Users" tab "Add" a user
** Login: vbuser
** Authorization: Public key
** User can use: Shell
* Copy the public rsa key from your Ubuntu VM and save it in `C:\Program Files (x86)\freeSSHd\vbuser` with no extension


Install VM
----------------------------------------

1. Grab the ISO from http://archive.ubuntu.com/ubuntu/dists/precise/main/installer-amd64/current/images/netboot/mini.iso
2. Install with
  * username: user
  * password: password
  * Select software: OpenSSH server
3. Set Network Adapter 1 to Bridged Adapter
4. Grab the IP address: `ifconfig`
5. On your development VM do (replace `IP_ADDRESS` with the IP address you grabbed in the previous step) `sudo sh -c 'echo IP_ADDRESS machinesvm >> /etc/hosts'`
6. Take a snapshot of the new VM
7. Finally, try `rake vm:win:kill` to close the running VM

