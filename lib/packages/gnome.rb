task :gnome, 'Set Gnome display preferences' do
  run configure '/apps/metacity/general/titlebar_font' => 'Arial Bold 10',
    '/apps/metacity/general/num_workspaces' => 1,
    '/apps/nautilus/preferences/desktop_font' => 'Sans 9',
    '/apps/nautilus/preferences/default_folder_viewer' => 'compact_view',
    '/desktop/gnome/interface/font_name' => 'Sans 9',
    '/desktop/gnome/interface/document_font_name' => 'Sans 9',
    '/desktop/gnome/interface/monospace_font_name' => 'Monospace 10'
end

