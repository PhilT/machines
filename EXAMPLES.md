It's easy to add new packages if you need something new on your current install.
I added the following to `packages/printer.rb`:

    task :printer, 'Install Samsung Unified Linux Drivers' do
      sudo deb 'http://www.bchemnet.com/suldr/ debian extra', :key => 'http://www.bchemnet.com/suldr/suldr.gpg', :name => 'Samsung'
      sudo install 'samsungmfp-data'
    end

I added it to my `Machinesfile`:

    package :printer

Then ran it locally:

    machines build task=printer machine=Desktop host=localhost user=phil hostname=ignored

Now the drivers for my printer are installed.

