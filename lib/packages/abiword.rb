task :abiword, 'Install a lightweight word processor' do
  sudo install ['abiword']
end

task :abiword_associations, 'Setup file associations for Abiword' do
  mimetypes = 'application/x-abiword;application/msword;application/rtf;'
  mimetypes.split(';').each do |mimetype|
    run append "#{mimetype}=abiword.desktop", :to => '.local/share/applications/mimeapps.list'
  end
end

