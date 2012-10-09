task :amazon_mp3, 'Download and install MP3 downloader from Amazon' do
  sudo install 'http://www.hilltopyodeler.com/packages/AmazonMP3-InstallerForUbuntuNewerThan-9.04.tar.gz', :as => :dpkg
end

