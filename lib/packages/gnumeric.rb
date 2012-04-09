task :gnumeric, 'Install gnumeric lightweight spreadsheet' do
  sudo install ['gnumeric']
end

task :gnumeric_associations, 'Setup file associations for Gnumeric' do
  mimetypes = 'application/x-gnumeric;application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;text/csv;application/msexcel'
  mimetypes.split(';').each do |mimetype|
    run append "#{mimetype}=gnumeric.desktop", :to => '.local/share/applications/mimeapps.list'
  end
end

