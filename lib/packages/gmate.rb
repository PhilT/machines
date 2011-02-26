dir  = File.join appsroot, 'gmate'
install 'git://github.com/PhilT/gmate.git', :to => dir, :as => username, :args => '-n'
configure username, '/apps/gedit-2/plugins/active-plugins' => %w(text_tools smart_indent align rails_hotkeys trailsave gemini rubyonrailsloader gedit_openfiles quickhighlightmode completion time docinfo filebrowser snippets spell indent)
indent = '/apps/gedit-2/plugins/smart_indent'
configure username, "#{indent}/haml_tab_size" => 2, "#{indent}/js_tab_size" => 2, "#{indent}/markdown_tab_size" => 2, "#{indent}/plain_text_tab_size" => 2, "#{indent}/sass_tab_size" => 2, "#{indent}/yaml_tab_size" => 2
configure username, '/apps/gedit-2/preferences/ui/toolbar/toolbar_visible' => false
editor = '/apps/gedit-2/preferences/editor/'
configure username, "#{editor}bracket_matching/bracket_matching" => true
configure username, "#{editor}current_line/highlight_current_line" => true
configure username, "#{editor}cursor_position/restore_cursor_position" => true
configure username, "#{editor}line_numbers/display_line_numbers" => true
configure username, "#{editor}right_margin/display_right_margin" => true
configure username, "#{editor}right_margin/right_margin_position" => 120
configure username, "#{editor}colors/scheme" => 'railscasts'
configure username, "#{editor}tabs/insert_spaces" => true
configure username, "#{editor}tabs/tabs_size" => 2
configure username, "#{editor}wrap_mode/wrap_mode" => 'GTK_WRAP_NONE'
configure username, "#{editor}save/create_backup_copy" => false

