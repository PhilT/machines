task :gmate, 'Clone gmate for gEdit from Github and set some preferences and plugins' do
  dir = File.join AppConf.appsroot, 'gmate'

  run git_clone 'git://github.com/gmate/gmate.git', :to => 'workspace/gmate'
  run 'cd workspace/gmate && echo \n | ./install.sh'

  run configure '/apps/gedit-2/plugins/active-plugins' => %w(text_tools smart_indent align rails_hotkeys trailsave gemini rubyonrailsloader gedit_openfiles quickhighlightmode completion time docinfo filebrowser snippets spell indent tabswitch)

  indent = '/apps/gedit-2/plugins/smart_indent'
  run configure "#{indent}/haml_tab_size" => 2,
    "#{indent}/js_tab_size" => 2,
    "#{indent}/markdown_tab_size" => 2,
    "#{indent}/plain_text_tab_size" => 2,
    "#{indent}/sass_tab_size" => 2,
    "#{indent}/yaml_tab_size" => 2

  editor = '/apps/gedit-2/preferences/editor/'
  run configure "#{editor}bracket_matching/bracket_matching" => true,
    "#{editor}current_line/highlight_current_line" => true,
    "#{editor}cursor_position/restore_cursor_position" => true,
    "#{editor}line_numbers/display_line_numbers" => true,
    "#{editor}right_margin/display_right_margin" => true,
    "#{editor}right_margin/right_margin_position" => 120,
    "#{editor}colors/scheme" => 'railscasts',
    "#{editor}tabs/insert_spaces" => true,
    "#{editor}tabs/tabs_size" => 2,
    "#{editor}wrap_mode/wrap_mode" => 'GTK_WRAP_NONE',
    "#{editor}save/create_backup_copy" => false
  run configure '/apps/gedit-2/preferences/ui/toolbar/toolbar_visible' => false
end

